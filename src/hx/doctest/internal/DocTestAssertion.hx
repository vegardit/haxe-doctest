/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal;

import hx.doctest.internal.Logger.SourceLocation;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class DocTestAssertion {
    
    public var filePath(default, null):String;
    public var fileName(default, null):String;
    public var lineNumber(default,null):Int;
    public var assertion(default,null):String;
    public var charStart(default,null):Int;
    public var charEnd(default, null):Int;
    
    public function new(filePath:String, fileName:String, lineNumber:Int, assertion:String, charStart:Int, charEnd:Int) {
        this.lineNumber = lineNumber;
        this.assertion = assertion;
        this.charStart = charStart;
        this.charEnd = charEnd;
        this.filePath = filePath;
        this.fileName = fileName;
    }
    
    public function getSourceLocation(fullPath:Bool = true):SourceLocation {
        return { filePath: fullPath ? filePath : fileName, lineNumber: lineNumber, charStart: charStart, charEnd: charEnd };
    }
    
    public function getPosInfos(fullPath:Bool = true):haxe.PosInfos {
        return { fileName: fullPath ? filePath : fileName, lineNumber: lineNumber, className: "", methodName:"" }
    }
}
