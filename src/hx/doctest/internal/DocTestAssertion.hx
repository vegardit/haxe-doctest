/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

import hx.doctest.internal.Logger.SourceLocation;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class DocTestAssertion {

    public var file(default, null):SourceFile;
    public var lineNumber(default,null):Int;
    public var expression(default,null):String;
    public var charStart(default,null):Int;
    public var charEnd(default, null):Int;

    inline
    public function new(file:SourceFile, lineNumber:Int, expression:String, charStart:Int, charEnd:Int) {
        this.file = file;
        this.lineNumber = lineNumber;
        this.expression = expression;
        this.charStart = charStart;
        this.charEnd = charEnd;
    }

    public function getSourceLocation(fullPath:Bool = true):SourceLocation {
        return {
            filePath: fullPath ? file.filePath : file.fileName,
            lineNumber: lineNumber,
            charStart: charStart,
            charEnd: charEnd
        };
    }

    public function getPosInfos(fullPath:Bool = true):haxe.PosInfos {
        return {
            fileName: fullPath ? file.filePath : file.fileName,
            lineNumber: lineNumber,
            className: "",
            methodName: ""
        }
    }
}
