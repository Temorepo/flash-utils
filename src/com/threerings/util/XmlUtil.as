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

import com.threerings.util.Enum;
import com.threerings.util.StringUtil;

public class XmlUtil
{
    /**
     * Parse the 'value' object into XML safely. This is equivalent to <code>new XML(value)</code>
     * but offers protection from other code that may have changing the default settings
     * used for parsing XML. Also, if you would like to use non-standard parsing settings
     * this method will protect other code from being broken by you.
     *
     * @param value the value to parse into XML.
     * @param settings an Object containing your desired XML settings, or null (or omitted) to
     * use the default settings.
     * @see XML#setSettings()
     */
    public static function newXML (value :Object, settings :Object = null) :XML
    {
        return safeOp(function () :* {
            return new XML(value);
        }, settings) as XML;
    }

    /**
     * Call toString() on the specified XML object safely. This is equivalent to
     * <code>xml.toString()</code> but offers protection from other code that may have changed
     * the default settings used for stringing XML. Also, if you would like to use the
     * non-standard printing settings this method will protect other code from being
     * broken by you.
     *
     * @param xml the xml value to Stringify.
     * @param settings an Object containing your desired XML settings, or null (or omitted) to
     * use the default settings.
     * @see XML#toString()
     * @see XML#setSettings()
     */
    public static function toString (xml :XML, settings :Object = null) :String
    {
        return safeOp(function () :* {
            return xml.toString();
        }, settings) as String;
    }

    /**
     * Call toXMLString() on the specified XML object safely. This is equivalent to
     * <code>xml.toXMLString()</code> but offers protection from other code that may have changed
     * the default settings used for stringing XML. Also, if you would like to use the
     * non-standard printing settings this method will protect other code from being
     * broken by you.
     *
     * @param xml the xml value to Stringify.
     * @param settings an Object containing your desired XML settings, or null (or omitted) to
     * use the default settings.
     * @see XML#toXMLString()
     * @see XML#setSettings()
     */
    public static function toXMLString (xml :XML, settings :Object = null) :String
    {
        return safeOp(function () :* {
            return xml.toXMLString();
        }, settings) as String;
    }

    /**
     * Perform an operation on XML that takes place using the specified settings, and
     * restores the XML settings to their previous values.
     *
     * @param fn a function to be called with no arguments.
     * @param settings an Object containing your desired XML settings, or null (or omitted) to
     * use the default settings.
     *
     * @return the return value of your function, if any.
     * @see XML#setSettings()
     * @see XML#settings()
     */
    public static function safeOp (fn :Function, settings :Object = null) :*
    {
        var oldSettings :Object = XML.settings();
        try {
            XML.setSettings(settings); // setting to null resets to all the defaults
            return fn();
        } finally {
            XML.setSettings(oldSettings);
        }
    }

    public static function hasChild (xml :XML, name :String) :Boolean
    {
        return xml.child(name).length() > 0;
    }

    public static function getSingleChild (xml :XML, name :String, defaultValue :* = undefined) :XML
    {
        var child :XML = xml.child(name)[0];
        if (null == child) {
            if (undefined !== defaultValue) {
                return defaultValue;
            } else {
                throw new XmlReadError(
                    "error accessing child '" + name + "': child does not exist",
                    xml);
            }
        }

        return child;
    }

    public static function hasAttribute (xml :XML, name :String) :Boolean
    {
        return (null != xml.attribute(name)[0]);
    }

    public static function getStringArrayAttr (xml :XML, name :String, stringMapping :Array,
        defaultValue :* = undefined) :int
    {
        return getAttr(xml, name, defaultValue,
            function (attrString :String) :int {
                return parseStringMember(attrString, stringMapping);
            });
    }

    public static function getUintAttr (xml :XML, name :String, defaultValue :* = undefined) :uint
    {
        return getAttr(xml, name, defaultValue, StringUtil.parseUnsignedInteger);
    }

    public static function getIntAttr (xml :XML, name :String, defaultValue :* = undefined) :int
    {
        return getAttr(xml, name, defaultValue, StringUtil.parseInteger);
    }

    public static function getNumberAttr (xml :XML, name :String, defaultValue :* = undefined)
        :Number
    {
        return getAttr(xml, name, defaultValue, StringUtil.parseNumber);
    }

    public static function getBooleanAttr (xml :XML, name :String, defaultValue :* = undefined)
        :Boolean
    {
        return getAttr(xml, name, defaultValue, StringUtil.parseBoolean);
    }

    public static function getStringAttr (xml :XML, name :String, defaultValue :* = undefined)
        :String
    {
        return getAttr(xml, name, defaultValue);
    }

    public static function getEnumAttr (xml :XML, name :String, enumClazz :Class,
        defaultValue :* = undefined) :*
    {
        return getAttr(xml, name, defaultValue,
            function (value :String) :Enum {
                return Enum.valueOf(enumClazz, value);
            });
    }

    public static function getAttr (xml :XML, name :String, defaultValue :*,
        parseFunction :Function = null) :*
    {
        var value :*;

        // read the attribute; throw an error if it doesn't exist (unless we have a default value)
        var attr :XML = xml.attribute(name)[0];
        if (null == attr) {
            if (undefined !== defaultValue) {
                return defaultValue;
            } else {
                throw new XmlReadError(
                    "error reading attribute '" + name + "': attribute does not exist",
                    xml);
            }
        }

        // try to parse the attribute
        try {
            value = (null != parseFunction ? parseFunction(attr) : attr);
        } catch (e :ArgumentError) {
            throw new XmlReadError("error reading attribute '" + name + "': " + e.message, xml);
        }

        return value;
    }

    protected static function parseStringMember (stringVal :String, stringMapping :Array) :int
    {
        var value :int;
        var foundValue :Boolean;

        // try to map the attribute value to one of the Strings in stringMapping
        for (var ii :int = 0; ii < stringMapping.length; ++ii) {
            if (String(stringMapping[ii]) == stringVal) {
                value = ii;
                foundValue = true;
                break;
            }
        }

        if (!foundValue) {
            // we couldn't perform the mapping - generate an appropriate error string
            var errString :String = "could not convert '" + stringVal +
                "' to the correct value (must be one of: ";
            for (ii = 0; ii < stringMapping.length; ++ii) {
                errString += String(stringMapping[ii]);
                if (ii < stringMapping.length - 1) {
                    errString += ", ";
                }
            }
            errString += ")";

            throw new ArgumentError(errString);
        }

        return value;
    }
}
}
