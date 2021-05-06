/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.example;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class ExampleTools {

   /**
    * Returns a new array with size <b>times</b> filled with <b>item</b>.
    * <br/>
    * <b>Examples:</b>
    * <pre><code>
    * >>> ExampleTools.toArray("foo", 2) == [ "foo", "foo" ]
    * >>> ExampleTools.toArray("foo", 1) == [ "foo" ]
    * >>> ExampleTools.toArray("foo", 0) == []
    * >>> ExampleTools.toArray(null, 0)  == []
    * >>> ExampleTools.toArray("", 0)    == []
    * >>> ExampleTools.toArray("foo", 0) !== []
    * >>> ExampleTools.toArray(null, 0)  !== []
    * >>> ExampleTools.toArray("", 0)    !== []
    * </code></pre>
    */
   public static function toArray<T>(item:T, times:Int):Array<T> {
      final arr = [];
      for (i in 0...times) arr.push(item);
      return arr;
   }

   /**
    * <pre><code>
    * >>> ExampleTools.toPos(null, null) == { x:null, y:null }
    * >>> ExampleTools.toPos(1, 2)       == { x:1, y:2 }
    * >>> ExampleTools.toPos(1, 2)       == { y:2, x:1 }
    * >>> ExampleTools.toPos(null, null) !== { x:null, y:null }
    * >>> ExampleTools.toPos(1, 2)       !== { x:1, y:2 }
    * >>> ExampleTools.toPos(1, 2)       !== { y:2, x:1 }
    * </code></pre>
    */
   public static function toPos(x: Null<Int>, y: Null<Int>): {x:Null<Int>, y:Null<Int>}
      return {x: x, y: y}

   #if (sys && (foo || bar))
   /**
    * >>> ExampleTools.neverTestMe1() == true
    */
   public static function neverTestMe1():Bool
      return false;
   #elseif (sys && flash)
   /**
    * >>> ExampleTools.neverTestMe1() == true
    */
   public static function neverTestMe2():Bool
      return false;
   #else
   /**
    * >>> ExampleTools.alwaysTestMe() == true
    */
   public static function alwaysTestMe():Bool
      return true;
   #end
}
