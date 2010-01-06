//
// $Id$
//
// Flash Utils library - general purpose ActionScript utility code
// Copyright (C) 2007-2010 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/ooolib/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.threerings.ui {

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;

import flash.utils.Dictionary;
import flash.utils.Timer;

import flash.utils.getTimer;

/**
 * A very simple class that adapts the KeyboardEvents generated by some source and altering
 * (or blocking) the key repeat rate.
 */
public class KeyRepeatLimiter extends EventDispatcher
{
    /**
     * Create a KeyRepeatLimiter that will be limiting key repeat events from
     * the specified source.
     *
     * @param limitRate 0 to block all key repeats, or a millisecond value specifying how often
     * to dispatch KEY_DOWN events while the key is being held down. The rate will be limted
     * by the frame rate of the enclosing SWF.
     */
    public function KeyRepeatLimiter (source :IEventDispatcher, limitRate :int = 0)
    {
        _source = source;
        _limitRate = limitRate;

        _source.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        _source.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
    }

    /**
     * Dispose of this KeyRepeatBlocker.
     */
    public function shutdown () :void
    {
        _source.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
        _source.removeEventListener(KeyboardEvent.KEY_UP, handleKeyUp);

        // shut down any timers
        for each (var val :* in _down) {
            if (val is Array) {
                ((val as Array)[0] as Timer).stop();
            }
        }
        _down = new Dictionary();
    }

    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        var oldVal :* = _down[event.keyCode];
        if (oldVal === undefined) {
            _down[event.keyCode] = (_limitRate > 0) ? getTimer() : 0;

        } else if ((oldVal is Number) && _limitRate > 0) {
            var timeUntilRepeat :Number = _limitRate - (getTimer() - Number(oldVal));

            var t :Timer = new Timer((timeUntilRepeat <= 0) ? _limitRate : timeUntilRepeat);
            t.addEventListener(TimerEvent.TIMER, handleTimerEvent);
            _down[event.keyCode] = [ t, event ];
            t.start();
            if (timeUntilRepeat > 0) {
                // don't dispatch this event, wait for our first repeat time
                return;
            }

        } else {
            // eat the event
            return;
        }

        // otherwise, dispatch the event
        dispatchEvent(event);
    }

    protected function handleKeyUp (event :KeyboardEvent) :void
    {
        var oldVal :* = _down[event.keyCode];
        if (oldVal !== undefined) {
            if (oldVal is Array) {
                ((oldVal as Array)[0] as Timer).stop();
            }
            delete _down[event.keyCode];
        }

        // always dispatch an up
        dispatchEvent(event);
    }

    protected function handleTimerEvent (event :TimerEvent) :void
    {
        // dispatch the key event associated with this timer
        for each (var val :* in _down) {
            if (val is Array) {
                var arr :Array = val as Array;
                var timer :Timer = arr[0] as Timer;
                if (timer == event.target) {
                    if (timer.delay != _limitRate) {
                        timer.reset();
                        timer.delay = _limitRate;
                        timer.start();
                    }
                    dispatchEvent(arr[1] as KeyboardEvent);
                    break;
                }
            }
        }
    }

    /** Our source. */
    protected var _source :IEventDispatcher;

    /** Tracks whether a key is currently being held down. */
    protected var _down :Dictionary = new Dictionary();

    protected var _limitRate :int;
}
}
