/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, http://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.CallStack;

using StringTools;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class DocTestUtils {

    public static function exceptionStackAsString():String {
        var stack = CallStack.exceptionStack();
        var i = -1;
        for (elem in stack) {
            i++;
            switch(elem) {
                case FilePos(elem2, file, line):
                    if (file.startsWith("hx/doctest")) {
                        stack = stack.slice(0, i);
                        break;
                    }
                    if (elem2 != null) switch(elem2) {
                        case Method(classname, method):
                            if (classname.startsWith("hx.doctest.")) {
                                stack = stack.slice(0, i);
                                break;
                            }
                        default:
                    }
                case Method(classname, method):
                    if (classname.startsWith("hx.doctest.")) {
                        stack = stack.slice(0, i);
                        break;
                    }
                default:
            }
        }
        return "  " + CallStack.toString(stack).split("\n").join("\n  ") + "\n";
    }

    public static function equals(left:Dynamic, right:Dynamic):Bool {

        // compare arrays
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

        // match regular pattern
        if (Std.is(right, EReg)) {
            return cast(right, EReg).match(Std.string(left));
        }

        // compare enums
        if (Reflect.isEnumValue(left) && Reflect.isEnumValue(right)) {
            var leftEnum:EnumValue = left;
            var rightEnum:EnumValue = right;
            return leftEnum.equals(rightEnum);
        }

        // compare anonymous structures
        if (Reflect.isObject(left) && Reflect.isObject(right)) {
            var clsLeft = Type.getClass(left);
            var clsNameLeft = clsLeft == null ? null : Type.getClassName(clsLeft);
            var clsRight = Type.getClass(right);
            var clsRightName = clsRight == null ? null : Type.getClassName(clsRight);

            if (clsNameLeft == null && clsRightName == null) {
                var clsLeftFields = Reflect.fields(left);
                clsLeftFields.sort(function (x, y) return x > y ? 1 : x == y ? 0 : -1);
                var clsRightFields = Reflect.fields(left);
                clsRightFields.sort(function (x, y) return x > y ? 1 : x == y ? 0 : -1);
                if (equals(clsLeftFields, clsRightFields)) {
                    for (f in clsLeftFields) {
                        if (!equals(Reflect.field(clsLeft, f), Reflect.field(clsRight, f)))
                            return false;
                    }
                    return true;
                }
            }
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

    #if sys
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
