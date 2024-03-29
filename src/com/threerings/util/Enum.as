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

import flash.utils.Dictionary;

/**
 * Base enum class for actionscript. Works pretty much like enums in Java, only you've got
 * to do one or two things.
 *
 * To use, you'll want to subclass and have something like the following:
 *
 * public final class Foo extends Enum
 * {
 *     public static const ONE :Foo = new Foo("ONE");
 *     public static const TWO :Foo = new Foo("TWO");
 *     finishedEnumerating(Foo);
 *
 *     / **  {at}private * /
 *     public function Foo (name :String)
 *     {
 *         super(name);
 *     }
 *
 *     public static function valueOf (name :String) :Foo
 *     {
 *         return Enum.valueOf(Foo, name) as Foo;
 *     }
 *
 *     public static function values () :Array
 *     {
 *         return Enum.values(Foo);
 *     }
 * }
 *
 * Important notes for Enum implementors:
 *  - make your class final
 *  - create a constructor that calls super(name)
 *  - declare your enum constants const, and with the same String as their name.
 *  - call finishedEnumerating() at the end of your constants.
 *  - your enum objects should be immutable
 *  - implement a static valueOf() and values() methods for extra points, as above.
 *
 * Note for Enum users: The same Enum class in different ApplicationDomains could cause confusion,
 * as the Enums will not be equal (neither will their Class objects, or in all probabability,
 * the Hashable, Equalable, or Comparable classes, so there could be larger problems.
 */
public class Enum
    implements Hashable, Comparable
{
    /**
     * Call this constructor in your enum subclass constructor.
     */
    public function Enum (name :String)
    {
        const clazz :Class = ClassUtil.getClass(this);
        if (Boolean(_blocked[clazz])) {
            throw new Error("You may not just construct an enum!");

        } else if (name == null) {
            throw new ArgumentError("null is invalid.");
        }

        var list :Array = _enums[clazz] as Array;
        if (list == null) {
            list = [];
            _enums[clazz] = list;
        } else {
            for each (var enum :Enum in list) {
                if (enum.name() === name) {
                    throw new ArgumentError(Joiner.args("Duplicate enum", name));
                }
            }
        }
        list.push(this);

        // now, actually construct
        _name = name;
    }

    /**
     * Get the name of this enum.
     */
    public final function name () :String
    {
        return _name;
    }

    /**
     * Get the ordinal of this enum.
     * Note that you should not use the ordinal in normal cases, as it may change if a new
     * enum is defined. Ordinals should only be used if you are writing a data structure
     * that generically handles enums in an efficient manner, and you are never persisting
     * anything where the ordinal can change.
     */
    public final function ordinal () :int
    {
        return (_enums[ClassUtil.getClass(this)] as Array).indexOf(this);
    }

    // from Hashable
    public final function equals (other :Object) :Boolean
    {
        // enums are singleton
        return (other === this);
    }

    // from Hashable
    public final function hashCode () :int
    {
        return ordinal();
    }

    /**
     * Return the String representation of this enum.
     */
    public function toString () :String
    {
        return _name;
    }

    /**
     * Return the primitive value of this Object.
     * The default implementation for Enums is to return the ordinal.
     */
    public function valueOf () :Object
    {
        return ordinal();
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        if (!ClassUtil.isSameClass(this, other)) {
            throw new ArgumentError("Not same class");
        }
        return Comparators.compareInts(this.ordinal(), Enum(other).ordinal());
    }

    /**
     * Turn a String name into an Enum constant.
     */
    public static function valueOf (clazz :Class, name :String) :Enum
    {
        for each (var enum :Enum in values(clazz)) {
            if (enum.name() === name) {
                return enum;
            }
        }
        throw new ArgumentError(Joiner.pairs("No such enum", "class", clazz, "name", name));
    }

    /**
     * Get all the enums of the specified class, or null if it's not an enum.
     */
    public static function values (clazz :Class) :Array
    {
        var arr :Array = _enums[clazz] as Array;
        if (arr == null) {
            throw new ArgumentError(Joiner.pairs("Not an enum", "class", clazz));
        }
        return arr.concat(); // return a copy, so that callers may not fuxor
    }

    /**
     * This should be called by your enum subclass after you've finished enumating the enum
     * constants. See the example in the class header documentation.
     */
    protected static function finishedEnumerating (clazz :Class) :void
    {
        _blocked[clazz] = true;
    }

    /** The String name of this enum value. */
    protected var _name :String;

    /** An array of enums for each enum class. */
    private static const _enums :Dictionary = new Dictionary(true);

    /** Is further instantiation of enum constants for a class allowed? */
    private static const _blocked :Dictionary = new Dictionary(true);

    finishedEnumerating(Enum); // do not allow any enums in this base class
}
}
