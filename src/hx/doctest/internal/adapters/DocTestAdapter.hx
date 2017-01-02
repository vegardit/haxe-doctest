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
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:dox(hide)
@:abstract
class DocTestAdapter {

    public function getFrameworkName():String {
        throw "Not implemented";
    }
    
    public function generateTestFail(src:SourceFile, errorMsg:String):Expr {
        throw "Not implemented";
    }
    
    public function generateTestSuccess(src:SourceFile):Expr {
        throw "Not implemented";
    }
    
    public function generateTestMethod(methodName:String, descr:String,assertions:Array<Expr>):Field {
        var contextPos = Context.currentPos();
        var meta = [{name:":keep", pos: contextPos}];
        return {
            name: methodName,
            doc: descr,
            meta: meta,
            access: [APublic],
            kind: FFun({
                ret:null, 
                args:[], 
                expr: { expr: EBlock(assertions), pos: contextPos}
            }),
            pos: contextPos
        };
    }
}
