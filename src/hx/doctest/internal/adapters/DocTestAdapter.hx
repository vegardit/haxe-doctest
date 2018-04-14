/*
 * Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal.adapters;

import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
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

    public function generateTestMethod(methodName:String, descr:String, assertions:Array<Expr>):Field {
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

    public function onFinish(contextFields:Array<Field>) {

    }
}
