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
    public var filePath:String;
    public var fileName:String;
    public var haxePackage:String;
    public var haxeModuleName:String;
    public var haxeModuleFQName:String;
    public var currentLine(default, null):LineType = null;
    public var currentLineNumber(default, null) = 0;

    var lines:Array<String>;

    public function new(filePath:String, docTestIdentifier:String) {
        Logger.log(INFO, 'Scanning [$filePath]...');
        this.filePath = filePath;
        this.docTestIdentifier = docTestIdentifier;
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

    public function nextLine():Bool {
        try {
            while (!isLastLine()) {
                currentLineNumber++;
                var line = fileInput.readLine().trim();

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

                var line = line.substringAfter(docTestIdentifier).trim();
                if (line == "")
                    continue;

                currentLine = DocTestAssertion(new DocTestAssertion(this, currentLineNumber, line, line.indexOf(docTestIdentifier) + docTestIdentifier.length, line.length));
                return true;
            }
        } catch(e:haxe.io.Eof) {
            // ignore --> bug in Haxe http://old.haxe.org/forum/thread/4494
        }
        fileInput.close();
        fileInput = null;
        return false;
    }

    inline
    public function isLastLine():Bool {
        return fileInput == null || fileInput.eof();
    }
}

enum LineType {
    DocTestAssertion(assertion:DocTestAssertion);
    CompilerConditionStart(condition:String);
    CompilerConditionElseIf(condition:String);
    CompilerConditionElse;
    CompilerConditionEnd;
}