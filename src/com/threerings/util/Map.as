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

package com.threerings.util {

/**
 * A Map is an object that maps keys to values.
 *
 * @see com.threerings.util.Maps
 */
public interface Map
{
    /**
     * Store a value in the map associated with the specified key.
     * Returns the previous value stored for that key, or undefined.
     */
    function put (key :Object, value :Object) :*;

    /**
     * Retrieve the value stored in this map for the specified key.
     * Returns the value, or undefined if there is no mapping for the key.
     */
    function get (key :Object) :*;

    /**
     * Returns true if the specified key exists in the map.
     */
    function containsKey (key :Object) :Boolean;

    /**
     * Removes the mapping for the specified key.
     * Returns the value that had been stored, or undefined.
     */
    function remove (key :Object) :*;

    /**
     * Return the current size of the map.
     */
    function size () :int;

    /**
     * Returns true if this map contains no elements.
     */
    function isEmpty () :Boolean;

    /**
     * Clear this map, removing all stored elements.
     */
    function clear () :void;

    /**
     * Return all the unique keys in this Map, in Array form.
     * The Array is not a 'view': it can be modified without disturbing
     * the Map from whence it came.
     */
    function keys () :Array;

    /**
     * Return all the values in this Map, in Array form.
     * The Array is not a 'view': it can be modified without disturbing
     * the Map from whence it came.
     */
    function values () :Array;

    /**
     * Call the specified function to iterate over the mappings in this Map.
     * Signature:
     * function (key :Object, value :Object) :void
     *    or
     * function (key :Object, value :Object) :Boolean
     *
     * If you return a Boolean, you may return <code>true</code> to indicate that you've
     * found what you were looking for, and halt iteration.
     */
    function forEach (fn :Function) :void;
}
}
