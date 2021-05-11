/*
 * Copyright (c) 2016-2021 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import haxe.EnumTools.EnumValueTools;
import hx.doctest.PosInfosExt;

using hx.doctest.internal.DocTestUtils;
using hx.doctest.internal.OS;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:nullSafety
@:noDoc @:dox(hide)
class Logger {

   private static final NEW_LINE = OS.isWindows ? "\r\n" : "\n";

   public static var maxLevel = Level.INFO;

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
   public static function log(level:Level, msg:String, ?pos:haxe.PosInfos):Void {
      if (EnumValueTools.getIndex(level) < EnumValueTools.getIndex(Logger.maxLevel))
         return;

      var posExt:PosInfosExt = cast pos;
      var charsOfLine:String = "";
      if (posExt.charStart != null && posExt.charEnd != null) {
         charsOfLine = 'characters ${posExt.charStart}-${posExt.charEnd}: ';
      }

      switch (level) {
         case DEBUG:
            #if debug
               haxe.Log.trace('$charsOfLine[DEBUG] ${msg}', pos);
            #end

         case ERROR:
            #if (sys && !hl) // TODO don't write to STDERR on hl, results in strange output for TestRunner#runAndExit()
               // on sys targets we directly write to STDERR
               Sys.stdout().flush();
               Sys.stderr().writeString((pos == null ? "" : '${pos.fileName}:${pos.lineNumber}: ') + '$charsOfLine[ERROR] ${msg}${NEW_LINE}');
               Sys.stderr().flush();
            #else
               haxe.Log.trace('$charsOfLine[ERROR] ${msg}', pos);
            #end

         default:
            haxe.Log.trace('$charsOfLine[${level}] ${msg}', pos);
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
