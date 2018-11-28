/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import hx.doctest.internal.Logger.SourceLocation;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class DocTestAssertion {

    public var filePath(default, null):String;
    public var fileName(default, null):String;
    public var lineNumber(default,null):Int;
    public var assertion(default,null):String;
    public var charStart(default,null):Int;
    public var charEnd(default, null):Int;

    inline
    public function new(filePath:String, fileName:String, lineNumber:Int, assertion:String, charStart:Int, charEnd:Int) {
        this.lineNumber = lineNumber;
        this.assertion = assertion;
        this.charStart = charStart;
        this.charEnd = charEnd;
        this.filePath = filePath;
        this.fileName = fileName;
    }

    public function getSourceLocation(fullPath:Bool = true):SourceLocation {
        return {
            filePath: fullPath ? filePath : fileName,
            lineNumber: lineNumber,
            charStart: charStart,
            charEnd: charEnd
        };
    }

    public function getPosInfos(fullPath:Bool = true):haxe.PosInfos {
        return {
            fileName: fullPath ? filePath : fileName,
            lineNumber: lineNumber,
            className: "",
            methodName: ""
        }
    }
}
