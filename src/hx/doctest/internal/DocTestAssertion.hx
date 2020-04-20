/*
 * Copyright (c) 2016-2020 Vegard IT GmbH (https://vegardit.com) and contributors.
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:nullSafety
@:noDoc @:dox(hide)
class DocTestAssertion {

   public final expression:String;
   public final pos:haxe.PosInfos;
   public final charsOfLine:Range;

   public function new(file:SourceFile, expression:String, lineNumber:Int, charStart:Int, charEnd:Int) {
      this.expression = expression;
      pos = {
         fileName: file.filePath,
         lineNumber: lineNumber,
         className: "",
         methodName: ""
      };
      charsOfLine = { start: charStart, end: charEnd };
   }
}
