/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
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
    public function new(file:SourceFile, expression:String, lineNumber:Int, charStart:Int, charEnd:Int) {
        this.file = file;
        this.expression = expression;
        this.lineNumber = lineNumber;
        this.charStart = charStart;
        this.charEnd = charEnd;
    }

    public function getSourceLocation():SourceLocation {
        return {
            filePath: file.filePath,
            fileName: file.fileName,
            lineNumber: lineNumber,
            charStart: charStart,
            charEnd: charEnd
        };
    }

    public function getPosInfos():haxe.PosInfos {
        return {
            fileName: file.fileName,
            lineNumber: lineNumber,
            className: "",
            methodName: ""
        }
    }
}
