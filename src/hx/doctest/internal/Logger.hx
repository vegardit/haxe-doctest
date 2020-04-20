/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.EnumTools.EnumValueTools;

using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:nullSafety
@:noDoc @:dox(hide)
class Logger {

   public static var maxLevel = Level.DEBUG;

   #if flash
   @:keep
   static final __static_init = {
      haxe.Log.trace = function(v:Dynamic, ?pos:haxe.PosInfos):Void
         flash.Lib.trace(pos == null ? '$v' : '${pos.fileName}:${pos.lineNumber}: $v');
   }
   #end


   /**
    * @param pos will be automatically populated by Haxe if not specified, see https://haxe.org/manual/debugging-posinfos.html
    */
   public static function log(level:Level, msg:String, ?charsOfLine:Range, ?pos:haxe.PosInfos):Void {
      if (EnumValueTools.getIndex(level) < EnumValueTools.getIndex(Logger.maxLevel))
         return;

      var charRange = charsOfLine == null ? "" : 'characters ${charsOfLine.start}-${charsOfLine.end}: ';
      switch (level) {
         case DEBUG:
            #if debug
               haxe.Log.trace('$charRange[DEBUG] ${msg}', pos);
            #end

         case ERROR:
            #if sys
               // on sys targets we directly write to STDERR
               Sys.stderr().writeString((pos == null ? "" : '${pos.fileName}:${pos.lineNumber}: ') + '$charRange[ERROR] ${msg}\n');
               Sys.stderr().flush();
            #else
               haxe.Log.trace('$charRange[ERROR] ${msg}', pos);
            #end

         default:
            haxe.Log.trace('$charRange[${level}] ${msg}', pos);
      }
   }
}


@:noDoc @:dox(hide)
enum Level {
   DEBUG;
   INFO;
   OK;
   WARN;
   ERROR;
   OFF;
}
