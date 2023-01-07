/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.macro.*;

/**
 * <b>IMPORTANT:</b> This class it not part of the API. Direct usage is discouraged.
 */
@:noDoc @:dox(hide)
@:noCompletion
class Macros {

   #if (haxe_ver < 4)
   static var __static_init(default, never) = {
      throw '[ERROR] As of haxe-doctest 3.0.0, Haxe 4.x or higher is required!';
   };
   #end

   macro
   public static function configureNullSafety() {
      #if (haxe_ver >= 4)
      haxe.macro.Compiler.nullSafety("hx.doctest",
         #if (haxe_ver < 4.1)
            Strict // Haxe 4.x does not have StrictThreaded
         #else
            StrictThreaded
         #end
      );
      #end
      return macro {}
   }
}
