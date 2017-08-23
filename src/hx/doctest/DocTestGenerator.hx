/*
 * Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package hx.doctest;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

import hx.doctest.internal.*;
import hx.doctest.internal.adapters.*;

using StringTools;
using hx.doctest.internal.DocTestUtils;

/**
 * The class contains the <code>generateDocTests</code> macro that inserts  unit test
 * methods in the annotated class based on assertions found in the Haxedoc of module files.
 *
 * @author Sebastian Thomschke, Vegard IT GmbH
 */
class DocTestGenerator {

    static var __static_init = {
        #if (haxe_ver <= 3.2)
            throw 'ERROR: haxe-doctests requires Haxe 3.2 or higher!';
        #end
    };

    static var MAX_ASSERTIONS_PER_TEST_METHOD(default, never) =
        Context.defined("lua") ?  30 : // to avoid "too many local variables" with Lua target
        100; // to avoid "error: code too large" with Java target

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
    public static function generateDocTests(srcFolder:String = "src", srcFilePathPattern:String = ".+\\.hx$", docTestIdentifier:String = "* >>>"):Array<Field> {

        var doctestAdapter = getDocTestAdapter();

        var contextFields = Context.getBuildFields();

        /*
         * ensure no test method gets DCE-ed by automatically adding @:keep to the class
         */
        Context.getLocalClass().get().meta.add(":keep", [], Context.currentPos());

        var totalAssertionsCount = 0;

        /*
         * iterate over all matched files
         */
        Logger.log(INFO, 'Activated via @:build on [${Context.getLocalClass().get().module}]');
        Logger.log(INFO, 'Generating test cases for test framework [${doctestAdapter.getFrameworkName()}]...');
        DocTestUtils.walkDirectory(srcFolder, new EReg(srcFilePathPattern, ""), function(srcFilePath) {
            var src = new SourceFile(srcFilePath, docTestIdentifier);

            var testMethodsCount = 0;
            var testMethodAssertions = new Array<Expr>();

            /*
             * iterate over all code lines of the Haxe file
             */
            while (src.gotoNextDocTestAssertion()) {

                // process "throws" assertion
                if (src.currentDocTestAssertion.assertion.indexOf("throws ") > -1) {
                    // poor man's solution until I figure out how to add import statements
                    var doctestLineFQ = new EReg("(^|[\\s(=<>!:])" + src.haxeModuleName + "(\\s?[(.<=])", "g").replace(src.currentDocTestAssertion.assertion, "$1" + src.haxeModuleFQName + "$2");
                    totalAssertionsCount++;

                    var left = doctestLineFQ.substringBeforeLast("throws ").trim();
                    var right = doctestLineFQ.substringAfterLast("throws ").trim();

                    var leftExpr:Expr = try {
                        Context.parse(left, Context.currentPos());
                    } catch (e:Dynamic) {
                        testMethodAssertions.push(doctestAdapter.generateTestFail(src, 'Failed to parse left side: $e'));
                        continue;
                    }

                    var rightExpr:Expr = right == "nothing" ? macro "nothing": try {
                        Context.parse(right, Context.currentPos());
                    } catch (e:Dynamic) {
                        testMethodAssertions.push(doctestAdapter.generateTestFail(src, 'Failed to parse right side: $e'));
                        continue;
                    }

                    var testSuccessExpr = doctestAdapter.generateTestSuccess(src);
                    var testFailedExpr = doctestAdapter.generateTestFail(src, "Expected `$right` but was `$left`.");

                    testMethodAssertions.push(macro {
                        var left:Dynamic = "nothing";
                        try { $leftExpr; } catch (ex:Dynamic) left = ex;
                        var right:Dynamic;
                        try { right = $rightExpr; } catch (ex:Dynamic) right = "exception: " + ex;

                        if (hx.doctest.internal.DocTestUtils.equals(left, right)) {
                            $testSuccessExpr;
                        } else {
                            if (Std.is(right, EReg) && cast(right, EReg).match(Std.string(left))) {
                                $testSuccessExpr;
                            } else {
                                $testFailedExpr;
                            }
                        }
                    });

                // process comparison assertion
                } else {
                    // poor man's solution until I figure out how to add import statements
                    var doctestLineFQ = new EReg("(^|[\\s(=<>!:])" + src.haxeModuleName + "(\\s?[(.<=])", "g").replace(src.currentDocTestAssertion.assertion, "$1" + src.haxeModuleFQName + "$2");
                    totalAssertionsCount++;

                    var doctestExpr = try {
                        Context.parse(doctestLineFQ, Context.currentPos());
                    } catch (e:Dynamic) {
                        testMethodAssertions.push(doctestAdapter.generateTestFail(src, 'Failed to parse assertion: $e'));
                        continue;
                    }

                    var leftExpr:Expr = null;
                    var rightExpr:Expr = null;
                    var comparator:Binop = null;
                    switch(doctestExpr.expr) {
                        case EBinop(op, l, r):
                            switch (op) {
                                case OpEq, OpNotEq, OpLte, OpLt, OpGt, OpGte:
                                    comparator = op;
                                default:
                                    testMethodAssertions.push(doctestAdapter.generateTestFail(src, "Assertion is missing one of the valid comparison operators: == != <= < > =>"));
                                    continue;
                            }
                            leftExpr = l;
                            rightExpr = r;
                        default:
                            testMethodAssertions.push(doctestAdapter.generateTestFail(src, "Assertion is missing one of the valid comparison operators: == != <= < > =>"));
                            continue;
                    }

                    var comparisonExpr:Expr = null;
                    var testSuccessExpr = doctestAdapter.generateTestSuccess(src);
                    var testFailedExpr = null;
                    switch(comparator) {
                        case OpEq:
                            comparisonExpr = macro hx.doctest.internal.DocTestUtils.equals(left, right);
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' does not equal '$right'.");
                        case OpNotEq:
                            comparisonExpr = macro !hx.doctest.internal.DocTestUtils.equals(left, right);
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' equals '$right'.");
                        case OpLte:
                            comparisonExpr = macro left <= right;
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' is not lower than or equal '$right'.");
                        case OpLt:
                            comparisonExpr = macro left < right;
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' is not lower than '$right'.");
                        case OpGt:
                            comparisonExpr = macro left > right;
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' is not greater than'$right'.");
                        case OpGte:
                            comparisonExpr = macro left >= right;
                            testFailedExpr = doctestAdapter.generateTestFail(src, "Left side '$left' is not greater than or equal '$right'.");
                        default: throw "Should never be reached";
                    }

                    testMethodAssertions.push(macro {
                        var left:Dynamic;
                        try { left = $leftExpr; } catch (ex:Dynamic) left = "exception: " + ex + hx.doctest.internal.DocTestUtils.exceptionStackAsString();
                        var right:Dynamic;
                        try { right = $rightExpr; } catch (ex:Dynamic) right = "exception: " + ex + hx.doctest.internal.DocTestUtils.exceptionStackAsString();

                        if ($comparisonExpr) {
                            $testSuccessExpr;
                        } else {
                            $testFailedExpr;
                        }
                    });
                }

                // generate a new testMethod if required
                if (testMethodAssertions.length == MAX_ASSERTIONS_PER_TEST_METHOD ||
                    (!Std.is(doctestAdapter, TestrunnerDocTestAdapter) && testMethodAssertions.length > 0) ||  // for haxe-unit and munit we create a new test-method per assertion
                    (Std.is(doctestAdapter, TestrunnerDocTestAdapter) && testMethodAssertions.length > 0 && src.isLastLine())
                ) {
                    testMethodsCount++;
                    var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                    Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');
                    contextFields.push(doctestAdapter.generateTestMethod(testMethodName, 'Doc Testing [${src.filePath}] #${testMethodsCount}', testMethodAssertions));
                    testMethodAssertions = new Array<Expr>();
                }
            }

            // generate a new testMethod if required
            if (testMethodAssertions.length > 0) {
                testMethodsCount++;
                var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');
                contextFields.push(doctestAdapter.generateTestMethod(testMethodName, 'Doc Testing [${src.filePath}] #${testMethodsCount}', testMethodAssertions));
            }
        });

        Logger.log(INFO, 'Generated $totalAssertionsCount test assertions.');
        return contextFields;
    }

    static function getDocTestAdapter():DocTestAdapter {
        var clazz:ClassType = Context.getLocalClass().get();

        while (true) {
            if (clazz.module == "hx.doctest.DocTestRunner") return new TestrunnerDocTestAdapter();
            if (clazz.module == "haxe.unit.TestCase") return new HaxeUnitDocTestAdapter();
            if (clazz.superClass == null) break;
            clazz = clazz.superClass.t.get();
        }
        // if no known super class was found, we expect it to be a MUnit test case
         return new MUnitDocTestAdapter();
    }
}
#end
