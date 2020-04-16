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
    static var __static_init = {
        haxe.Log.trace = function(v:Dynamic, ?pos: haxe.PosInfos ):Void {
            flash.Lib.trace((pos==null ? "" : pos.fileName + ":" + pos.lineNumber + ": ") + v);
        }
    }
    #end

    inline
    public static function log(level:Level, msg:String, ?loc:SourceLocation, ?pos:haxe.PosInfos):LogEvent {
        var event = new LogEvent(level, msg, loc, pos);
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
    var filePath : String;
    var fileName : String;
    var lineNumber : Int;
    var charStart: Int;
    var charEnd: Int;
}

@:noDoc @:dox(hide)
class LogEvent {
    public var level(default, null):Level;
    public var msg(default, null):String;
    public var loc(default, null):SourceLocation;
    public var pos(default, null):haxe.PosInfos;

    inline
    public function new(level:Level, msg:String, ?loc:SourceLocation, ?pos:haxe.PosInfos) {
        this.level = level;
        this.msg = msg;
        this.loc = loc;
        this.pos = pos;
    }

    public function log(detailedErrorLocation = false) {
        if (level == DEBUG) {
            #if debug
            if (loc == null) {
                haxe.Log.trace('[DEBUG] ${msg}', pos);
            } else {
                haxe.Log.trace('[DEBUG] ${msg}', { fileName: loc.filePath, lineNumber: loc.lineNumber, className: "", methodName: "" });
            }
            #end
        } else if (level == ERROR) {
            #if sys
                if(detailedErrorLocation || loc == null)
                    Sys.stderr().writeString(toString() + '\n');
                else
                    Sys.stderr().writeString(("/" + loc.filePath).substringAfterLast("/") + ':${loc.lineNumber}: [${level}] ${msg}\n');
                Sys.stderr().flush();
            #else
                if (loc == null) {
                    haxe.Log.trace('[ERROR] ${msg}', pos);
                } else {
                    haxe.Log.trace('[ERROR] ${msg}', { fileName: loc.filePath, lineNumber: loc.lineNumber, className: "", methodName: "" });
                }
            #end
        } else {
            if (loc == null) {
                haxe.Log.trace('[${level}] ${msg}', pos);
            } else {
                haxe.Log.trace('[${level}] ${msg}', { fileName: loc.filePath, lineNumber: loc.lineNumber, className: "", methodName: "" });
            }
        }
    }

    /**
     * Generates test log string
     * ISSUE: IF LogEvent was contructed without loc argument (it's optional) 'detailed' has no affect
     * 
     * @param [detailed=false] generate log string with file names and lines info. ERROR logs detailed even when false set
     * @return String test log info
     */
    public function toString(detailed:Bool = false):String {
        // @tynrare at 16.04.20: 
        // About 'loc != null' line
        // In my opinion we just do not need loc and pos separated, they carry almost same data
        // So in this code LogEvent constructor called so much times that i can't trace all places SourceLocation was passed as null
        return loc != null && (detailed || level == ERROR) ?
            '${loc.filePath}:${loc.lineNumber}: characters ${loc.charStart}-${loc.charEnd}: [${level}] ${msg}' :
            '${pos.fileName}:${pos.lineNumber}: [${level}] ${msg}'; 
    }
}
