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

public class FileUtil
{
    /**
     * Returns the substring composed of the characters after the last '.' in the supplied string.
     * The substring will be converted to lowercase.
     */
    public static function getDotSuffix (filename :String) :String
    {
        var dotIndex :int = filename.lastIndexOf(".");
        return (dotIndex >= 0 ? filename.substr(dotIndex + 1).toLowerCase() : "");
    }

}

}
