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
import hx.doctest.internal.Logger;
import hx.doctest.internal.SourceFile;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * The class contains the <code>generateDocTests</code> macro that inserts  unit test 
 * methods in the annotated class based on assertions found in the Haxedoc of module files.
 * 
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class DocTestGenerator {
    
    static inline var MAX_ASSERTIONS_PER_TEST_METHOD = 100; // to avoid "error: code too large" for java target
    
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
        Logger.log(INFO, 'Activated via @:build on [${Context.getLocalClass().get().module}]');
        Logger.log(INFO, 'Generating test cases for test framework [${testFramework}]...');
        DocTestUtils.walkDirectory(srcFolder, new EReg(srcFilePathPattern, ""), function(srcFilePath) {
            var src = new SourceFile(srcFilePath);

            var testMethodsCount = 0;
            var testMethodAssertions = new Array<Expr>();

            /*
             * iterate over all code lines of the Haxe file
             */
            while(src.gotoNextDocTestAssertion()) {

                if (src.currentDocTestAssertion.assertion.endsWith(";")) {
                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                testsFailed.push(
                                    hx.doctest.internal.Logger.log(ERROR, 
                                        '${src.currentDocTestAssertion.assertion} --> test assertion must not end with a semicolon (;)',
                                        $v{src.currentDocTestAssertion.getSourceLocation()}
                                    )
                                );
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                currentTest.success = false;
                                currentTest.error   = "test assertion must not end with a semicolon (;)";
                                currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
                                throw currentTest;
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                massive.munit.Assert.fail("test assertion must not end with a semicolon (;)", $v{src.currentDocTestAssertion.getPosInfos()});
                            });
                    }


                } else if (src.currentDocTestAssertion.assertion.indexOf("==") > -1) {
                    // poor man's solution until I figure out how to add import statements
                    var doctestLineFQ = new EReg(src.haxeModuleName + "(\\s?[(.<])", "g").replace(src.currentDocTestAssertion.assertion, src.haxeModuleFQName + "$1");
                    totalAssertionsCount++;
                    
                    var left = doctestLineFQ.substringBeforeLast("==").trim();
                    var right = doctestLineFQ.substringAfterLast("==").trim();
                    var leftExpr = try {
                        Context.parse(left, Context.currentPos());
                    } catch (e:Dynamic) {
                        switch(testFramework) {
                            case DOCTEST:
                                testMethodAssertions.push(macro {
                                    testsFailed.push(
                                        hx.doctest.internal.Logger.log(ERROR, 
                                            '${src.currentDocTestAssertion.assertion} --> failed to parse left side [$left]: $e',
                                            $v{src.currentDocTestAssertion.getSourceLocation()}
                                        )
                                    );
                                });
                            case HAXE_UNIT:
                                testMethodAssertions.push(macro {
                                    currentTest.done = true;
                                    currentTest.success = false;
                                    currentTest.error   = 'Failed to parse left side [$left]: $e';
                                    currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
                                    throw currentTest;
                                });
                            case MUNIT:
                                testMethodAssertions.push(macro {
                                    massive.munit.Assert.fail('Failed to parse left side [$left]: $e', $v{src.currentDocTestAssertion.getPosInfos()});
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
                                    testsFailed.push(
                                        hx.doctest.internal.Logger.log(ERROR, 
                                            '${src.currentDocTestAssertion.assertion} --> failed to parse right side [$right]: $e',
                                            $v{src.currentDocTestAssertion.getSourceLocation()}
                                        )
                                    );
                                });
                            case HAXE_UNIT:
                                testMethodAssertions.push(macro {
                                    currentTest.done = true;
                                    currentTest.success = false;
                                    currentTest.error   = 'Failed to parse right side [$right]: $e';
                                    currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
                                    throw currentTest;
                                });
                            case MUNIT:
                                testMethodAssertions.push(macro {
                                    massive.munit.Assert.fail('Failed to parse right side [$right]: $e', $v{src.currentDocTestAssertion.getPosInfos()});
                                });
                        }
                        continue;
                    }

                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                try {
                                    var left:Dynamic = $leftExpr;
                                    var right:Dynamic = $rightExpr;
                                    if (hx.doctest.internal.DocTestUtils.equals(left, right)) {
                                        haxe.Log.trace('[OK] ${src.currentDocTestAssertion.assertion}', $v{src.currentDocTestAssertion.getPosInfos(false)});
                                        testsOK++;
                                    } else {
                                        testsFailed.push(hx.doctest.internal.Logger.log(ERROR, '${src.currentDocTestAssertion.assertion} --> expected [' + right + '] but was [' + left + ']', $v{src.currentDocTestAssertion.getSourceLocation()}));
                                    }
                                } catch (e:Dynamic) {
                                    testsFailed.push(
                                        hx.doctest.internal.Logger.log(ERROR, 
                                            '${src.currentDocTestAssertion.assertion} --> exception occured: ' + e,
                                            $v{src.currentDocTestAssertion.getSourceLocation()}
                                        )
                                    );
                                }
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                if (hx.doctest.internal.DocTestUtils.equals($leftExpr, $rightExpr)) {
                                    print('\n${src.fileName}:${src.currentLineNumber} [OK] ' + $v{src.currentDocTestAssertion.assertion});
                                } else {
                                    currentTest.success = false;
                                    currentTest.error   = "expected `" +  $rightExpr + "` but was `" + $leftExpr + "`";
                                    currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
                                    throw currentTest;
                                }
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                if (hx.doctest.internal.DocTestUtils.equals($leftExpr, $rightExpr)) {
                                    mconsole.Console.info('\n${src.fileName}:${src.currentLineNumber} [OK] ' + $v{src.currentDocTestAssertion.assertion});
                                } else {
                                    massive.munit.Assert.fail("expected `" + $rightExpr + "` but was `" + $leftExpr + "`", $v{src.currentDocTestAssertion.getPosInfos()});
                                }
                            });
                    }
                    
                } else {
                    switch(testFramework) {
                        case DOCTEST:
                            testMethodAssertions.push(macro {
                                testsFailed.push(
                                    hx.doctest.internal.Logger.log(ERROR, 
                                        '${src.currentDocTestAssertion.assertion} --> test assertion is missing equals operator (==)', 
                                        $v{src.currentDocTestAssertion.getSourceLocation()}
                                    )
                                );
                            });
                        case HAXE_UNIT:
                            testMethodAssertions.push(macro {
                                currentTest.done = true;
                                currentTest.success = false;
                                currentTest.error   = "test assertion is missing equals operator (==)";
                                currentTest.posInfos = $v{src.currentDocTestAssertion.getPosInfos()};
                                throw currentTest;
                            });
                        case MUNIT:
                            testMethodAssertions.push(macro {
                                massive.munit.Assert.fail('test assertion is missing equals operator (==)', $v{src.currentDocTestAssertion.getPosInfos()});
                            });
                    }
                }

                if (testMethodAssertions.length == MAX_ASSERTIONS_PER_TEST_METHOD ||
                    (testFramework != DOCTEST && testMethodAssertions.length > 0) ||
                    (testFramework == DOCTEST && testMethodAssertions.length > 0 && src.isLastLine())
                ) {
                    testMethodsCount++;
                    var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                    Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');

                    if(testFramework == DOCTEST) {
                        testMethodAssertions.unshift(macro {
                            var pos = { fileName:  $v{Context.getLocalModule()}, lineNumber: 1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
                            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
                            hx.doctest.internal.Logger.log(INFO, 'Doc Testing [${src.filePath}] #${testMethodsCount}...', pos);
                            hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
                        });
                    }
                    var meta = [{name:":keep", pos: contextPos}];
                    if (testFramework == MUNIT) {
                        meta.push({name: "Test", pos: contextPos});
                    }
                    contextFields.push({
                        name: testMethodName,
                        doc: 'Doc Tests #${testMethodsCount} of ${src.fileName}',
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
            
            if (testMethodAssertions.length > 0) {
                testMethodsCount++;
                var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');

                if(testFramework == DOCTEST) {
                    testMethodAssertions.unshift(macro {
                        var pos = { fileName:  $v{Context.getLocalModule()}, lineNumber: 1, className: $v{Context.getLocalClass().get().name}, methodName:"" };
                        hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
                        hx.doctest.internal.Logger.log(INFO, 'Doc Testing [${src.filePath}] #${testMethodsCount}...', pos);
                        hx.doctest.internal.Logger.log(INFO, '**********************************************************', pos);
                    });
                }
                var meta = [{name:":keep", pos: contextPos}];
                if (testFramework == MUNIT) {
                    meta.push({name: "Test", pos: contextPos});
                }
                contextFields.push({
                    name: testMethodName,
                    doc: 'Doc Tests #${testMethodsCount} of ${src.fileName}',
                    meta: meta,
                    access: [APublic],
                    kind: FFun({
                        ret:null, 
                        args:[], 
                        expr: { expr: EBlock(testMethodAssertions), pos: contextPos}
                    }),
                    pos: contextPos
                });
            }
        });
            
        Logger.log(INFO, 'Generated $totalAssertionsCount test assertions.');
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
