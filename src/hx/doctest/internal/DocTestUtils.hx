/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.CallStack;
import haxe.Constraints.IMap;

using StringTools;

@:noDoc @:dox(hide)
class DocTestUtils {

   public static final GENERATED_TEST_METHOD_SUFFIX = "_doctest";

   inline //
   public static function currentPos(?pos:haxe.PosInfos):Null<haxe.PosInfos>
      return pos;


   /**
    * >>> DocTestUtils.deepEquals(null, null) == true
    * >>> DocTestUtils.deepEquals(null, "") == false
    * >>> DocTestUtils.deepEquals(1, 1) == true
    * >>> DocTestUtils.deepEquals(1, 2) == false
    * >>> DocTestUtils.deepEquals("a", "a") == true
    * >>> DocTestUtils.deepEquals("a", "b") == false
    * >>> DocTestUtils.deepEquals("HelloWorld", ~/.*world/i) == true
    * >>> DocTestUtils.deepEquals([1,1], [1,1]) == true
    * >>> DocTestUtils.deepEquals([1,1], [1,2]) == false
    * >>> DocTestUtils.deepEquals([1 => 1], [1 => 1]) == true
    * >>> DocTestUtils.deepEquals([1 => 1], [1 => 2]) == false
    */
   public static function deepEquals(left:Null<Dynamic>, right:Null<Dynamic>):Bool {
      if (left == right)
         return true;

      if (left == null || right == null)
         return false;

      // match regular pattern
      if (Std.isOfType(right, EReg))
         #if python @:nullSafety(Off) #end // TODO
      return cast(right, EReg).match(Std.string(left));

      if (Std.isOfType(left, String))
         return false;

      // compare arrays
      if (Std.isOfType(left, Array) && Std.isOfType(right, Array)) {
         final leftArr:Array<Dynamic> = left;
         final rightArr:Array<Dynamic> = right;
         if (leftArr.length == rightArr.length) {
            for (i in 0...leftArr.length)
               if (!deepEquals(leftArr[i], rightArr[i]))
                  return false;
            return true;
         }
         return false;
      }

      // compare maps
      if (Std.isOfType(left, IMap) && Std.isOfType(right, IMap)) {
         final leftMap:IMap<Dynamic, Dynamic> = cast left;
         final rightMap:IMap<Dynamic, Dynamic> = cast right;

         final leftKeys:Array<Dynamic> = [for (k in leftMap.keys()) k];
         final rightKeys:Array<Dynamic> = [for (k in rightMap.keys()) k];

         if (deepEquals(leftKeys, rightKeys)) {
            for (key in leftKeys)
               if (!deepEquals(leftMap.get(key), rightMap.get(key)))
                  return false;
            return true;
         }
         return false;
      }

      // compare enums
      if (Reflect.isEnumValue(left) && Reflect.isEnumValue(right)) {
         final leftEnum:EnumValue = left;
         final rightEnum:EnumValue = right;
         return Type.enumEq(leftEnum, rightEnum);
      }

      // compare objects and anonymous structures
      #if js @:nullSafety(Off) #end
      if (Reflect.isObject(left) && Reflect.isObject(right)) {
         final clsLeft = Type.getClass(left);
         final clsLeftName = clsLeft == null ? null : Type.getClassName(clsLeft);
         final clsRight = Type.getClass(right);
         final clsRightName = clsRight == null ? null : Type.getClassName(clsRight);

         if (clsLeftName != clsRightName)
            return false;

         final clsLeftFields = Reflect.fields(left);
         clsLeftFields.sort((x, y) -> x > y ? 1 : x == y ? 0 : -1);
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
         switch (elem) {
            case FilePos(elem2, file, line):
               if (file.startsWith("hx/doctest")) {
                  stack = stack.slice(0, i);
                  break;
               }
               if (elem2 != null) switch (elem2) {
                  case Method(classname, method):
                     if (classname != null && classname.startsWith("hx.doctest.")) {
                        stack = stack.slice(0, i);
                        break;
                     }
                  default:
               }
            case Method(classname, method):
               if (classname != null && classname.startsWith("hx.doctest.")) {
                  stack = stack.slice(0, i);
                  break;
               }
            default:
         }
      }

      #if lua @:nullSafety(Off) #end
      return "  " + CallStack.toString(stack).split("\n").join("\n  ") + "\n";
   }


   inline //
   public static function getFileName(filePath:String):String
      return substringAfterLast("/" + filePath.replace("\\", "/"), "/");


   #if macro
      public static function implementsInterface(clazz:haxe.macro.Type.ClassType, interfaceName:String):Bool {
         for (iface in clazz.interfaces)
            if (iface.t.toString() == interfaceName)
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
      public static function walkDirectory(directory:String, filePattern:EReg, onFile:String->Void):Void {
         var files:Array<String> = sys.FileSystem
            .readDirectory(directory)
            .map((s) -> '$directory/$s');

         while (files.length > 0) {
            var file = files.shift();
            if (file == null) continue;
            if (sys.FileSystem.isDirectory(file))
               files = files.concat(sys.FileSystem.readDirectory(file).map((s) -> '$file/$s'));
            else {
               file = file.replace("\\", "/");
               #if python @:nullSafety(Off) #end
               if (filePattern.match(file))
                  onFile(file);
            }
         }
      }
   #end
}
