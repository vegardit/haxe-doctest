/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.CallStack;
import haxe.macro.MacroStringTools;


using StringTools;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class DocTestUtils {

   public static function deepEquals(left:Dynamic, right:Dynamic):Bool {

      if (left == right)
         return true;

      // match regular pattern
      if (Std.is(right, EReg))
         return cast(right, EReg).match(Std.string(left));

      if (Std.is(left, String))
         return false;

      // compare arrays
      if (Std.is(left, Array) && Std.is(right, Array)) {
         if (left.length == right.length) {
            for (i in 0...left.length) {
               if (!deepEquals(left[i], right[i]))
                  return false;
            }
            return true;
         }
         return false;
      }

      // compare enums
      if (Reflect.isEnumValue(left) && Reflect.isEnumValue(right)) {
         final leftEnum:EnumValue = left;
         final rightEnum:EnumValue = right;
         return leftEnum.equals(rightEnum);
      }

      // compare objects and anonymous structures
      if (Reflect.isObject(left) && Reflect.isObject(right)) {
         final clsLeft = Type.getClass(left);
         final clsLeftName = clsLeft == null ? null : Type.getClassName(clsLeft);
         final clsRight = Type.getClass(right);
         final clsRightName = clsRight == null ? null : Type.getClassName(clsRight);

         if (clsLeftName != clsRightName)
            return false;

         final clsLeftFields = Reflect.fields(left);
         clsLeftFields.sort((x, y) ->  x > y ? 1 : x == y ? 0 : -1);
         final clsRightFields = Reflect.fields(right);
         clsRightFields.sort((x, y) -> x > y ? 1 : x == y ? 0 : -1);
         if (deepEquals(clsLeftFields, clsRightFields)) {
            for (fieldName in clsLeftFields) {
               if (!deepEquals(Reflect.field(left, fieldName), Reflect.field(right, fieldName)))
                  return false;
            }
            return true;
         }
      }

      return false;
   }


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


   #if macro
   public static function implementsInterface(clazz:haxe.macro.Type.ClassType, interfaceName:String):Bool {
      for(iface in clazz.interfaces)
         if(iface.t.toString() == interfaceName)
            return true;
      return false;
   }
   #end


   public static function substringAfter(str:String, sep:String):String {
      final foundAt = str.indexOf(sep);
      if (foundAt == -1) return "";
      return str.substring(foundAt + sep.length);
   }


   public static function substringAfterLast(str:String, sep:String):String {
      final foundAt = str.lastIndexOf(sep);
      if (foundAt == -1) return "";
      return str.substring(foundAt + sep.length);
   }


   public static function substringBefore(str:String, sep:String):String {
      final foundAt = str.indexOf(sep);
      if (foundAt == -1) return "";
      return str.substring(0, foundAt);
   }


   public static function substringBeforeLast(str:String, sep:String):String {
      final foundAt = str.lastIndexOf(sep);
      if (foundAt == -1) return "";
      return str.substring(0, foundAt);
   }


   #if (sys || macro)
   public static function walkDirectory(directory:String, filePattern:EReg, onFile:String -> Void):Void {
      var files:Array<String> = sys.FileSystem
         .readDirectory(directory)
         .map((s) -> '$directory/$s');

      while (files.length > 0) {
         var file = files.shift();
         if (sys.FileSystem.isDirectory(file)) {
            files = files.concat(sys.FileSystem.readDirectory(file).map((s) -> '$file/$s'));
         } else {
            file = file.replace("\\", "/");
            if(filePattern.match(file))
               onFile(file);
         }
      }
   }
   #end
}
