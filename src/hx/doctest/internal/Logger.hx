/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal;

using hx.doctest.internal.DocTestUtils;

enum Level {
    DEBUG;
    INFO;
    WARN;
    ERROR;
}

typedef SourceLocation = {
	var filePath : String;
	var lineNumber : Int;
	var charStart: Int;
    var charEnd: Int;
}

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

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class Logger {

    inline
    public static function log(level:Level, msg:String, ?loc:SourceLocation, ?pos:haxe.PosInfos):LogEvent {
        var event = new LogEvent(level, msg, loc, pos);
        event.log();
        return event;
    }
}
