/*
 * SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
 * SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

using StringTools;
using hx.doctest.internal.DocTestUtils;

@:noDoc @:dox(hide)
class SourceFile {
   static final REGEX_PACKAGE_NAME = ~/package\s+(([a-zA-Z_]{1}[a-zA-Z]*){2,10}\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,30}((\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,61})*)?)\s?;/g;

   public var currentLine(default, null):Null<LineType>;
   public var currentLineNumber(default, null) = 0;

   public var docTestIdentifier(default, null):String;
   public var docTestNextLineIdentifier(default, null):String;

   public var filePath(default, null):String;
   public var fileName(default, null):String;

   public var haxePackage(default, null):String;
   public var haxeModuleName(default, null):String;
   public var haxeModuleFQName(default, null):String;

   var fileInput:sys.io.FileInput;
   var lines:Array<String>;
   var lineAhead:String;


   public function new(filePath:String, docTestIdentifier:String, docTestNextLineIdentifier:String) {
      this.filePath = filePath;
      this.fileName = filePath.getFileName();
      this.docTestIdentifier = docTestIdentifier;
      this.docTestNextLineIdentifier = docTestNextLineIdentifier;

      Logger.log(INFO, 'Scanning [$filePath]...');
      fileInput = sys.io.File.read(filePath, false);
      haxePackage = "";
      try {
         while (!isLastLine()) {
            final line = fileInput.readLine();
            if (REGEX_PACKAGE_NAME.match(line)) {
               haxePackage = REGEX_PACKAGE_NAME.matched(1);
               break;
            }
         }
      } catch (e:haxe.io.Eof) {
         // ignore --> bug in Haxe http://old.haxe.org/forum/thread/4494
      }
      fileInput.seek(0, SeekBegin);

      haxeModuleName = fileName.substringBefore(".");
      haxeModuleFQName = haxePackage.length > 0 ? '$haxePackage.$haxeModuleName' : haxeModuleName;
   }


   public function isLastLine():Bool
      return fileInput == null || fileInput.eof();


   function extractCondition(line:String, startToken:String) {
      var condition = line.substringAfter(startToken);
      if (condition.contains("#else")) condition = condition.substringBefore("#else");
      if (condition.contains("/*")) condition = condition.substringBefore("/*");
      if (condition.contains("//")) condition = condition.substringBefore("//");
      return condition.trim();
   }


   public function nextLine():Bool {
      while (!isLastLine()) {
         var line:String;
         var lineTrimmed:String;
         try {
            line = lineAhead == null ? fileInput.readLine() : lineAhead;
            lineTrimmed = line.trim();
            lineAhead = null;
         } catch (e:haxe.io.Eof) {
            // bug in Haxe http://old.haxe.org/forum/thread/4494 / https://github.com/HaxeFoundation/haxe/issues/5418
            break;
         }
         currentLineNumber++;

         if (lineTrimmed.startsWith("#end")) {
            currentLine = CompilerConditionEnd;
            return true;
         }

         if (lineTrimmed.startsWith("#if ")) {
            currentLine = CompilerConditionStart(extractCondition(lineTrimmed, "#if "));
            return true;
         }

         if (lineTrimmed.startsWith("#elseif ")) {
            currentLine = CompilerConditionElseIf(extractCondition(lineTrimmed, "#elseif "));
            return true;
         }

         if (lineTrimmed.startsWith("#else if ")) {
            currentLine = CompilerConditionElseIf(extractCondition(lineTrimmed, "#else if "));
            return true;
         }

         if (lineTrimmed.startsWith("#else")) {
            currentLine = CompilerConditionElse;
            return true;
         }

         var docTestExpression = line.substringAfter(docTestIdentifier).trim();
         if (docTestExpression == "")
            continue;

         final docTestExpressionLineNumber = currentLineNumber;

         while (!isLastLine()) {
            try {
               lineAhead = fileInput.readLine().trim();
            } catch (e:haxe.io.Eof) {
               // bug in Haxe http://old.haxe.org/forum/thread/4494 / https://github.com/HaxeFoundation/haxe/issues/5418
               lineAhead = null;
               break;
            }
            final docTestExpressionNextLine = lineAhead.substringAfter(docTestNextLineIdentifier).trim();
            if (docTestExpressionNextLine == "") {
               break;
            } else {
               lineAhead = null;
               currentLineNumber++;
               docTestExpression = docTestExpression + "\n" + docTestExpressionNextLine;
            }
         }
         currentLine = DocTestAssertion(new DocTestAssertion(
            this,
            docTestExpression,
            docTestExpressionLineNumber,
            line.indexOf(docTestIdentifier) + docTestIdentifier.length,
            line.length
         ));
         return true;
      }

      if (fileInput != null) {
         fileInput.close();
         fileInput = null;
      }

      return false;
   }
}


enum LineType {
   DocTestAssertion(assertion:DocTestAssertion);
   CompilerConditionStart(condition:String);
   CompilerConditionElseIf(condition:String);
   CompilerConditionElse;
   CompilerConditionEnd;
}
