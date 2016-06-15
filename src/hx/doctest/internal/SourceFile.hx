/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest.internal;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class SourceFile {
    static var REGEX_PACKAGE_NAME = ~/package\s+(([a-zA-Z_]{1}[a-zA-Z]*){2,10}\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,30}((\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,61})*)?)\s?;/g;
    static inline var DOCTEST_IDENTIFIER = "* >>>";
    
    public var filePath:String;
    public var fileName:String;
    public var haxePackage:String;
    public var haxeModuleName:String;
    public var haxeModuleFQName:String;
    public var currentDocTestAssertion(default, null):DocTestAssertion = null;
    public var currentLineNumber(default, null) = 0;
    
    var lines:Array<String>;
    
    public function new(filePath:String) {
        trace('[INFO] Scanning [$filePath]...');
        this.filePath = filePath;
        fileName = filePath.substringAfterLast("/");

        var fileContent = sys.io.File.getContent(filePath);
        lines = fileContent.split("\n");
        if (!REGEX_PACKAGE_NAME.match(fileContent))
            haxePackage = "";
        else
            haxePackage = REGEX_PACKAGE_NAME.matched(1);
        haxeModuleName = fileName.substringBefore(".");
        haxeModuleFQName = haxePackage.length > 0 ? haxePackage + "." + haxeModuleName : haxeModuleName;
    }
    
    public function gotoNextDocTestAssertion():Bool {
        while (!isLastLine()) {
            currentLineNumber++;
            var line = lines[currentLineNumber - 1].substringAfter(DOCTEST_IDENTIFIER).trim();
            if (line == "") continue;
            currentDocTestAssertion = new DocTestAssertion(filePath, fileName, currentLineNumber, line, lines[currentLineNumber - 1].indexOf(DOCTEST_IDENTIFIER) + DOCTEST_IDENTIFIER.length, lines[currentLineNumber - 1].length);
            return true;
        }
        return false;
    }
    
    public function isLastLine():Bool {
        return currentLineNumber == lines.length;
    }
}
