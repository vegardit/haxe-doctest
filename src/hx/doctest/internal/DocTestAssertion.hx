/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

@:noDoc @:dox(hide)
class DocTestAssertion {

   public final expression:String;
   public final pos:PosInfosExt;


   public function new(file:SourceFile, expression:String, lineNumber:Int, charStart:Int, charEnd:Int) {
      this.expression = expression;
      pos = {
         fileName: file.filePath,
         lineNumber: lineNumber,
         className: "",
         methodName: "",
         charStart: charStart,
         charEnd: charEnd
      };
   }


   public function toString():String {
      return 'DocTestAssertion[pos="${pos.fileName}:${pos.lineNumber}", expr={ $expression }]';
   }
}
