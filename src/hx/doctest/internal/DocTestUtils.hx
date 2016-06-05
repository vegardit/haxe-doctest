/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal;

using StringTools;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class DocTestUtils {

    public static function equals(left:Dynamic, right:Dynamic):Bool {
        if (Std.is(left, Array) && Std.is(right, Array)) {
            if (left.length == right.length) {
                for (i in 0...left.length) {
                    if (!equals(left[i], right[i]))
                        return false;
                }
                return true;
            }
            return false;
        }
        return left == right;
    }
    
    public static function substringAfter(str:String, sep:String):String {
        var foundAt = str.indexOf(sep);
        if (foundAt == -1) return "";
        return str.substring(foundAt + sep.length);
    }
    
    public static function substringAfterLast(str:String, sep:String):String {
        var foundAt = str.lastIndexOf(sep);
        if (foundAt == -1) return "";
        return str.substring(foundAt + sep.length);
    }
    
    public static function substringBefore(str:String, sep:String):String {     
        var foundAt = str.indexOf(sep);
        if (foundAt == -1) return "";
        return str.substring(0, foundAt);
    }
    
    public static function substringBeforeLast(str:String, sep:String):String {       
        var foundAt = str.lastIndexOf(sep);
        if (foundAt == -1) return "";
        return str.substring(0, foundAt);
    }

    #if macro
	public static function walkDirectory(directory:String, filePattern:EReg, onFile:String -> Void):Void {
		var files:Array<String> = sys.FileSystem
			.readDirectory(directory)
			.map(function(s) return directory + "/" + s);

		while (files.length > 0) {
            var file = files.shift();
			if (sys.FileSystem.isDirectory(file)) {
                files = files.concat(sys.FileSystem
                    .readDirectory(file)
                    .map(function(s) return file + "/" + s)
                );
			} else {
                file = file.replace("\\", "/");
                if(filePattern.match(file))
                    onFile(file);
            }
		}
	}
    #end
}
