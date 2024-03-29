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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.SimpleButton;

import flash.geom.ColorTransform;

import com.threerings.display.ImageUtil;

/**
 * Takes a BitmapData and makes a button that brightens on hover and depresses when pushed.
 */
public class SimpleIconButton extends SimpleButton
{
    /**
     * Constructor. @see #setIcon()
     */
    public function SimpleIconButton (icon :*)
    {
        setIcon(icon);
    }

    /**
     * Update the icon for this button.
     *
     * @param icon a BitmapData, or Bitmap (from which the BitmapData will be extracted), or
     *             a Class that instantiates into either a BitmapData or Bitmap.
     */
    public function setIcon (icon :*) :void
    {
        var bmp :BitmapData = ImageUtil.toBitmapData(icon);
        if (bmp == null) {
            throw new Error("Unknown icon spec: must be a Bitmap or BitmapData, or a Class " +
                "that becomes one.");
        }

        const bright :ColorTransform = new ColorTransform(1.25, 1.25, 1.25);
        upState = new Bitmap(bmp);
        overState = new Bitmap(bmp);
        overState.transform.colorTransform = bright;
        downState = new Bitmap(bmp);
        downState.y = 1;
        downState.transform.colorTransform = bright;
        hitTestState = upState;
    }
}
}
