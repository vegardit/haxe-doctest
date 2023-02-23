/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

/**
 * <b>IMPORTANT:</b> This class it not part of the API. Direct usage is discouraged.
 */
@:noDoc @:dox(hide)
@:noCompletion
class OS {

   #if js
   static final isNodeJS:Bool = js.Syntax.code("(typeof process !== 'undefined') && (typeof process.release !== 'undefined') && (process.release.name === 'node')");
   #end

   public static var isWindows(default, never):Bool = {
      #if sys
         Sys.systemName() == "Windows";
      #else
         final os:String =
            #if flash
               flash.system.Capabilities.os
            #elseif js
               isNodeJS ? js.Syntax.code("process.platform") : js.Browser.navigator.platform
            #end;
            ~/win/i.match(os);
      #end
   }
}
