/*
 * Copyright (c) 2016 Vegard IT GmbH, http://vegardit.com
 * 
 * This software may be modified and distributed under the terms
 * of the MIT license. See the LICENSE.txt file for details.
 */
package hx.doctest;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.File;
import sys.FileSystem;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * The class contains the <code>generateDocTests</code> macro that inserts  unit test 
 * methods in the annotated class based on assertions found in the Haxedoc of module files.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class DocTestGenerator {

    static inline var DOCTEST_IDENTIFIER = "* >>>";
    static inline var MAX_ASSERTIONS_PER_TEST_METHOD = 200; // to avoid "error: code too large" for java target
    static var REGEX_PACKAGE_NAME = ~/package\s+(([a-zA-Z_]{1}[a-zA-Z]*){2,10}\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,30}((\.([a-zA-Z_]{1}[a-zA-Z0-9_]*){1,61})*)?)\s?;/g;
    
    /**
     * <pre><code>
     * @:build(hx.doctest.DocTestGenerator.generateDocTests("src", ".*\\.hx"))
     * 
     * </code></pre>
     * 
     * @param srcFolder location of the source folder to scan for doctests
     * @param srcFilePathPattern only files matching the given pattern are scanned for doctest assertions.
     *                           By default all files with the extension <code>.hx</code> are scanned.
     */
    public static function generateDocTests(srcFolder:String = "src", srcFilePathPattern:String = ".+\\.hx$"):Array<Field> {

        var testFramework = determineTestFramework();

        var contextFields = Context.getBuildFields();
        var contextPos = Context.currentPos();
        var totalAssertionsCount = 0;
        
        /*
         * iterate over all matched files
         */
        trace('[INFO] Activated via @:build on [${Context.getLocalClass().get().module}]');
        trace('[INFO] Generating test cases for test framework [$testFramework]...');
        DocTestUtils.walkDirectory(srcFolder, new EReg(srcFilePathPattern, ""), function(srcFilePath) {
                       
            trace('[INFO] Scanning [$srcFilePath]...');
            var srcFileContent = File.getContent(srcFilePath);
            
            /*
             * extract package name and import it's classes
             */
            if (!REGEX_PACKAGE_NAME.match(srcFileContent)) {
                throw '[$srcFilePath] is missing the package declaration.';
            }
            var srcFileName = srcFilePath.substringAfterLast("/");
            var srcFilePackage = REGEX_PACKAGE_NAME.matched(1);
            var srcFileModuleName = srcFileName.substringBefore(".");
            var srcFileModuleFQName = srcFilePackage + "." + srcFileModuleName;
            //trace("FOOO" + srcFilePackage);
            // Compiler.include(srcFileModuleFQName, false);

            var testMethodsCount = 0;
            var testMethodAssertions = new Array<Expr>();

            /*
             * iterate over all code lines of the Haxe file
             */
            var srcFileLines = srcFileContent.split("\n");
            for (i in 0...srcFileLines.length) {
                var srcFileLineNr = i + 1;
                
                // check for doctest assertions
                var doctestLine = srcFileLines[i].substringAfter(DOCTEST_IDENTIFIER).trim();

                if (doctestLine.endsWith(";")) {
                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                var pos = { fileName: '$srcFileName', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                haxe.Log.trace('$doctestLine', pos);
                                var msg = "  |--> FAIL: test assertion must not end with a semicolon (;)";
                                haxe.Log.trace(msg, pos);
                                testsFailed.push('  $srcFileName:$srcFileLineNr: $doctestLine\n  ' + msg);
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                currentTest.success = false;
                                currentTest.error   = "test assertion must not end with a semicolon (;)";
                                currentTest.posInfos = pos;
                                throw currentTest;
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: '${srcFileModuleName}', methodName:"?" };
                                massive.munit.Assert.fail("test assertion must not end with a semicolon (;)", pos);
                            });
                    }

                } else if (doctestLine.indexOf("==") > -1) {
                    // poor man's solution until I figure out how to add import statements
                    var doctestLineFQ = new EReg('$srcFileModuleName(\\s?[(.<])', "g").replace(doctestLine, srcFileModuleFQName + "$1");
                    
                    totalAssertionsCount++;
                    
                    var left = doctestLineFQ.substringBeforeLast("==").trim();
                    var right = doctestLineFQ.substringAfterLast("==").trim();
                    var leftExpr = try {
                        Context.parse(left, Context.currentPos());
                    } catch (e:Dynamic) {
                        switch(testFramework) {
                            case DOCTEST:
                                testMethodAssertions.push(macro {
                                    var pos = { fileName: '$srcFileName', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                    haxe.Log.trace('$doctestLine', pos);
                                    var msg = '  |--> FAIL: Failed to parse left side [$left]: $e';
                                    haxe.Log.trace(msg, pos);
                                    testsFailed.push('  $srcFileName:$srcFileLineNr: $doctestLine\n  ' + msg);
                                });
                            case HAXE_UNIT:
                                testMethodAssertions.push(macro {
                                    currentTest.done = true;
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                    currentTest.success = false;
                                    currentTest.error   = 'Failed to parse left side [$left]: $e';
                                    currentTest.posInfos = pos;
                                    throw currentTest;
                                });
                            case MUNIT:
                                testMethodAssertions.push(macro {
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: '${srcFileModuleName}', methodName:"?" };
                                    massive.munit.Assert.fail('Failed to parse left side [$left]: $e', pos);
                                });
                        }
                        continue;
                    }

                    var rightExpr = try {
                        Context.parse(right, Context.currentPos());
                    } catch (e:Dynamic) {
                        switch(testFramework) {
                            case DOCTEST:
                                testMethodAssertions.push(macro {
                                    var pos = { fileName: '$srcFileName', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                    haxe.Log.trace('$doctestLine', pos);
                                    var msg = '  |--> FAIL: Failed to parse right side [$right]: $e';
                                    haxe.Log.trace(msg, pos);
                                    testsFailed.push('  $srcFileName:$srcFileLineNr: $doctestLine\n  ' + msg);
                                });
                            case HAXE_UNIT:
                                testMethodAssertions.push(macro {
                                    currentTest.done = true;
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                    currentTest.success = false;
                                    currentTest.error   = 'Failed to parse right side [$right]: $e';
                                    currentTest.posInfos = pos;
                                    throw currentTest;
                                });
                            case MUNIT:
                                testMethodAssertions.push(macro {
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: '${srcFileModuleName}', methodName:"?" };
                                    massive.munit.Assert.fail('Failed to parse right side [$right]: $e', pos);
                                });
                        }
                        continue;
                    }

                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                try {
                                    _compareResults($leftExpr, $rightExpr, '$doctestLine', pos);
                                } catch (e:Dynamic) {
                                    haxe.Log.trace('[FAIL] $doctestLine\n     |--> exception occured: ' + e, pos);
                                    testsFailed.push(pos.fileName + ":" + pos.lineNumber + ': [FAIL] $doctestLine\n   |--> exception occured: ' + e);
                                }
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                if (hx.doctest.internal.DocTestUtils.equals($leftExpr, $rightExpr)) {
                                    print('\n$srcFileName:$srcFileLineNr [OK] ' + $v{doctestLine});
                                } else {
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                    currentTest.success = false;
                                    currentTest.error   = "expected `" +  $rightExpr + "` but was `" + $leftExpr + "`";
                                    currentTest.posInfos = pos;
                                    throw currentTest;
                                }
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                if (hx.doctest.internal.DocTestUtils.equals($leftExpr, $rightExpr)) {
                                    mconsole.Console.info('\n$srcFileName:$srcFileLineNr [OK] ' + $v{doctestLine});
                                } else {
                                    var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: '${srcFileModuleName}', methodName:"?" };
                                    massive.munit.Assert.fail("expected `" + $rightExpr + "` but was `" + $leftExpr + "`", pos);
                                }
                            });
                    }
                    
                } else if (doctestLine != "") {
                    
                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                var pos = { fileName: '$srcFileName', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                haxe.Log.trace('$doctestLine', pos);
                                var msg = "  |--> FAIL: test assertion is missing equals operator (==)";
                                haxe.Log.trace(msg, pos);
                                testsFailed.push('  $srcFileName:$srcFileLineNr: $doctestLine\n  ' + msg);
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: "", methodName:"" };
                                currentTest.success = false;
                                currentTest.error   = "test assertion is missing equals operator (==)";
                                currentTest.posInfos = pos;
                                throw currentTest;
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                var pos = { fileName: '$srcFilePath', lineNumber: $v{srcFileLineNr}, className: '${srcFileModuleName}', methodName:"?" };
                                massive.munit.Assert.fail('test assertion is missing equals operator (==)', pos);
                            });
                    }
                }

                if (testMethodAssertions.length == MAX_ASSERTIONS_PER_TEST_METHOD ||
                    (testFramework != DOCTEST && testMethodAssertions.length > 0) ||
                    (testFramework == DOCTEST && testMethodAssertions.length > 0 && srcFileLineNr == srcFileLines.length)
                ) {
                    testMethodsCount++;
                    var testMethodName = 'test${srcFileModuleName}_$testMethodsCount';
                    #if debug
                    trace('[DEBUG] |--> Generating "${testMethodName}()"...');
                    #end

                    if(testFramework == DOCTEST) {
                        testMethodAssertions.unshift(macro {
                            var pos = { fileName:  $v{Context.getLocalModule()}, lineNumber: 1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
                            haxe.Log.trace('[INFO] **********************************************************', pos);
                            haxe.Log.trace('[INFO] Doc Testing [$srcFilePath] #${testMethodsCount}...', pos);
                            haxe.Log.trace('[INFO] **********************************************************', pos);
                        });
                    }
                    var meta = [{name:":keep", pos: contextPos}];
                    if (testFramework == MUNIT) {
                        meta.push({name: "Test", pos: contextPos});
                    }
                    contextFields.push({
                        name: testMethodName,
                        doc: 'Doc Tests #${testMethodsCount} of $srcFilePath',
                        meta: meta,
                        access: [APublic],
                        kind: FFun({
                            ret:null, 
                            args:[], 
                            expr: { expr: EBlock(testMethodAssertions), pos: contextPos}
                        }),
                        pos: contextPos
                    });
                    testMethodAssertions = new Array<Expr>();
                }
            }
        });
        
        trace('[INFO] Generated $totalAssertionsCount test assertions.');
        return contextFields;
    }
    
    static function determineTestFramework():TestFramework {
        var clazz:ClassType = Context.getLocalClass().get();

        while (true) {
            if (clazz.module == "hx.doctest.DocTestRunner") return DOCTEST;
            if (clazz.module == "haxe.unit.TestCase") return HAXE_UNIT;
            if (clazz.superClass == null) break;
            clazz = clazz.superClass.t.get();
        }
        // if no known super class was found, we expect it to be a MUnit test case
        return MUNIT;
    }
}

private enum TestFramework {
    DOCTEST;
    HAXE_UNIT;
    MUNIT;
}

#end
