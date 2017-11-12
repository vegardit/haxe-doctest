/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
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

    public function toString() {
        if (loc == null) {
            return '${pos.fileName}:${pos.lineNumber}: [${level}] ${msg}';
        }
        return '${loc.filePath}:${loc.lineNumber}: characters ${loc.charStart}-${loc.charEnd}: [${level}] ${msg}';
    }
}
