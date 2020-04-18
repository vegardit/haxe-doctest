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

   public final file:SourceFile;
   public final lineNumber:Int;
   public final expression:String;
   public final charStart:Int;
   public final charEnd:Int;


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
         lineNumber: lineNumber,
         charStart: charStart,
         charEnd: charEnd
      };
   }


   public function getPosInfos():haxe.PosInfos {
      return {
         fileName: file.filePath,
         lineNumber: lineNumber,
         className: "",
         methodName: ""
      }
   }
}
