/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest;

class TestMacros {

   macro //
   public static function fixSystemNameOnLua() {
      #if (haxe_ver < 4.3)
         /* Workaround for:
          * lua: ...cts-haxe\haxe-doctest\tools\..\target\lua\TestRunner.lua:1986: number/string expected, got nil
          * stack traceback:
          *    [C]: in function 'lower'
          *    ...cts-haxe\haxe-doctest\tools\..\target\lua\TestRunner.lua:1986: in function 'detectSupport'
          *    ...cts-haxe\haxe-doctest\tools\..\target\lua\TestRunner.lua:18533: in function '_hx_static_init'
          *    ...cts-haxe\haxe-doctest\tools\..\target\lua\TestRunner.lua:18650: in main chunk
          *    [C]: in ?
          * which for an unknown reason fails because somehow Sys.systemName() and lua.Boot.systemName() return null on Windows
          */
      if (haxe.macro.Context.defined("lua")) {
         final systemName:String = Sys.systemName();
         no.Spoon.bend('Sys', macro class {
            public static function systemName():String {
               return $v{systemName};
            }
         });
      }
      #end
      return macro {}
   }
}