/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
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
