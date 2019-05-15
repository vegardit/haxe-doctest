/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
 */
package hx.doctest.internal;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
@:noDoc @:dox(hide)
class SourceFile {
    static var REGEX_PACKAGE_NAME = ~/package\s+(([a-zA-Z_]{1}[a-zA-Z]*){2,10}\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,30}((\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,61})*)?)\s?;/g;

    var fileInput:sys.io.FileInput;
    public var docTestIdentifier:String;
    public var docTestNextLineIdentifier:String;
    public var filePath:String;
    public var fileName:String;
    public var haxePackage:String;
    public var haxeModuleName:String;
    public var haxeModuleFQName:String;
    public var currentLine(default, null):LineType = null;
    public var currentLineNumber(default, null) = 0;

    var lines:Array<String>;

    public function new(filePath:String, docTestIdentifier:String, docTestNextLineIdentifier:String) {
        Logger.log(INFO, 'Scanning [$filePath]...');
        this.filePath = filePath;
        this.docTestIdentifier = docTestIdentifier;
        this.docTestNextLineIdentifier = docTestNextLineIdentifier;
        fileName = filePath.substringAfterLast("/");

        fileInput = sys.io.File.read(filePath, false);
        haxePackage = "";

        try {
            while (!isLastLine()) {
                var line = fileInput.readLine();
                if (REGEX_PACKAGE_NAME.match(line)) {
                    haxePackage = REGEX_PACKAGE_NAME.matched(1);
                    break;
                }
            }
        } catch(e:haxe.io.Eof) {
            // ignore --> bug in Haxe http://old.haxe.org/forum/thread/4494
        }
        fileInput.seek(0, SeekBegin);

        haxeModuleName = fileName.substringBefore(".");
        haxeModuleFQName = haxePackage.length > 0 ? haxePackage + "." + haxeModuleName : haxeModuleName;
    }

    inline
    public function isLastLine():Bool {
        return fileInput == null || fileInput.eof();
    }

    var lineAhead:String = null;

    public function nextLine():Bool {
        while (!isLastLine()) {
            var line:String;
            try {
                line = lineAhead == null ? fileInput.readLine().trim() : lineAhead;
                lineAhead = null;
            } catch(e:haxe.io.Eof) {
                // bug in Haxe http://old.haxe.org/forum/thread/4494 / https://github.com/HaxeFoundation/haxe/issues/5418
                break;
            }
            currentLineNumber++;

            if (line == "#else") {
                currentLine = CompilerConditionElse;
                return true;
            }

            if (line == "#end") {
                currentLine = CompilerConditionEnd;
                return true;
            }

            if (line.startsWith("#if ")) {
                currentLine = CompilerConditionStart(line.substringAfter("#if "));
                return true;
            }

            if (line.startsWith("#elseif ")) {
                currentLine = CompilerConditionElseIf(line.substringAfter("#elseif "));
                return true;
            }

            var docTestExpression = line.substringAfter(docTestIdentifier).trim();
            if (docTestExpression == "")
                continue;
            var docTestExpressionLineNumber = currentLineNumber;

            while (!isLastLine()) {
                try {
                    lineAhead = fileInput.readLine().trim();
                } catch(e:haxe.io.Eof) {
                    // bug in Haxe http://old.haxe.org/forum/thread/4494 / https://github.com/HaxeFoundation/haxe/issues/5418
                    lineAhead = null;
                    break;
                }
                var docTestExpressionNextLine = lineAhead.substringAfter(docTestNextLineIdentifier).trim();
                if (docTestExpressionNextLine == "") {
                    break;
                } else {
                    lineAhead = null;
                    currentLineNumber++;
                    docTestExpression = docTestExpression + "\n" + docTestExpressionNextLine;
                }
            }
            currentLine = DocTestAssertion(new DocTestAssertion(this, docTestExpression, docTestExpressionLineNumber, line.indexOf(docTestIdentifier) + docTestIdentifier.length, line.length));
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