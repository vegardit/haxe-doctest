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

   #if (haxe_ver < 4.2)
      static var __static_init(default, never) = {
         throw '[ERROR] Haxe 4.2 or higher is required!';
      };
   #end


   macro //
   public static function configureNullSafety() {
      #if (haxe_ver >= 4.2)
         haxe.macro.Compiler.nullSafety("hx.doctest", StrictThreaded);
      #end
      return macro {}
   }
}
