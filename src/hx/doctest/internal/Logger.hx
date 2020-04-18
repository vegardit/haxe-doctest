/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class Logger {

   #if flash
   @:keep
   static final __static_init = {
      haxe.Log.trace = function(v:Dynamic, ?pos: haxe.PosInfos ):Void {
         flash.Lib.trace(pos == null ? '$v' : '${pos.fileName}:${pos.lineNumber}: $v');
      }
   }
   #end

   /**
    * @param pos will be automatically populated by Haxe if not specified, see https://haxe.org/manual/debugging-posinfos.html
    */
   public static function log(level:Level, msg:String, ?pos:haxe.PosInfos):LogEvent {
      final event = new LogEvent(level, msg, pos);
      event.log();
      return event;
   }
}


@:noDoc @:dox(hide)
enum Level {
   DEBUG;
   INFO;
   OK;
   WARN;
   ERROR;
}


@:noDoc @:dox(hide)
typedef SourceLocation = {
   var filePath: String;
   var lineNumber: Int;
   var charStart: Int;
   var charEnd: Int;
}



@:noDoc @:dox(hide)
class LogEvent {
   public final level:Level;
   public final msg:String;
   public final pos:Either2<SourceLocation,haxe.PosInfos>;


   inline
   private static function getPosInfosFromSourceLocation(loc:SourceLocation, withFullPath:Bool):haxe.PosInfos
      return {fileName: withFullPath ? loc.filePath : getFileName(loc.filePath) , lineNumber: loc.lineNumber, className: "", methodName: ""};

   inline
   private static function getFileName(filePath:String):String
      return ("/" + filePath).substringAfterLast("/");


   public function new(level:Level, msg:String, pos:Either2<SourceLocation,haxe.PosInfos>) {
      this.level = level;
      this.msg = msg;
      this.pos = pos;
   }


   public function log(withDetailedLocation = true):Void {
      switch(level) {
         case DEBUG:
            #if debug
            switch (pos.value){
               case a(loc): haxe.Log.trace('[DEBUG] ${msg}', getPosInfosFromSourceLocation(loc, withDetailedLocation));
               case b(loc): haxe.Log.trace('[DEBUG] ${msg}', loc);
            }
            #end

         case ERROR:
            #if sys
               // on sys targets we directly write to STDERR
               Sys.stderr().writeString('${toStringInternal(withDetailedLocation)}\n');
               Sys.stderr().flush();
            #else
               switch (pos.value){
                  case a(loc): haxe.Log.trace('[ERROR] ${msg}', getPosInfosFromSourceLocation(loc, withDetailedLocation));
                  case b(loc): haxe.Log.trace('[ERROR] ${msg}', loc);
               }
            #end

         default:
            switch (pos.value){
               case a(loc): haxe.Log.trace('[${level}] ${msg}', getPosInfosFromSourceLocation(loc, withDetailedLocation));
               case b(loc): haxe.Log.trace('[${level}] ${msg}', loc);
            }
      }
   }


   function toStringInternal(withDetailedLocation = true):String {
      switch (pos.value){
         //SourceLocation:
         case a(loc):
            if (withDetailedLocation)
               return '${loc.filePath}:${loc.lineNumber}: characters ${loc.charStart}-${loc.charEnd}: [${level}] ${msg}';
            return '${getFileName(loc.filePath)}:${loc.lineNumber}: [${level}] ${msg}';

         //haxe.PosInfos:
         case b(loc):
            var filePath = withDetailedLocation ? loc.fileName : getFileName(loc.fileName);
            return '${filePath}:${loc.lineNumber}: [${level}] ${msg}';
      }
   }


   public function toString():String
      return toStringInternal(true);
}
