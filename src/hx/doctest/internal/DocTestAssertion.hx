/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
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
