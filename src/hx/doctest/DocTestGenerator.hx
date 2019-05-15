/*
 * Copyright (c) 2016-2019 Vegard IT GmbH, https://vegardit.com
 * SPDX-License-Identifier: Apache-2.0
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

    @:keep
    static var __static_init = {
        #if (haxe_ver < 3.4)
            throw 'ERROR: haxe-doctests requires Haxe 3.4 or higher!';
        #end
    };

    static var MAX_ASSERTIONS_PER_TEST_METHOD(default, never) =
        Context.defined("lua") ?  #if (haxe_ver < 4) 20 #else 30 #end : // to avoid "too many local variables" with Lua target
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

        var parser = new hscript.Parser();
        var compilerConditions = new Array<Bool>();

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
            while (src.nextLine()) {
                switch(src.currentLine) {
                    case DocTestAssertion(assertion):

                        if (compilerConditions.indexOf(false) > -1)
                            continue;

                        // poor man's solution until I figure out how to add import statements
                        var doctestLineFQ = new EReg("(^|[\\s(=<>!:])" + src.haxeModuleName + "(\\s?[(.<=])", "g").replace(assertion.expression, "$1" + src.haxeModuleFQName + "$2");
                        totalAssertionsCount++;

                        // process "===" assertion
                        if (assertion.expression.indexOf(" === ") > -1) {

                            var left = doctestLineFQ.substringBeforeLast(" === ").trim();
                            var right = doctestLineFQ.substringAfterLast(" === ").trim();

                            var leftExpr:Expr = try {
                                Context.parse(left, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse left side: $ex'));
                                continue;
                            }

                            var rightExpr:Expr = try {
                                Context.parse(right, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse right side: $ex'));
                                continue;
                            }

                            var testSuccessExpr = doctestAdapter.generateTestSuccess(assertion);
                            var testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` not same instance as `$right`.");

                            testMethodAssertions.push(macro {
                                var left = $leftExpr;
                                var right = $rightExpr;
                                if (left == right)
                                    $testSuccessExpr;
                                else
                                    $testFailedExpr;
                            });
                        }

                        // process "!==" assertion
                        else if (assertion.expression.indexOf(" !== ") > -1) {

                            var left = doctestLineFQ.substringBeforeLast(" !== ").trim();
                            var right = doctestLineFQ.substringAfterLast(" !== ").trim();

                            var leftExpr:Expr = try {
                                Context.parse(left, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse left side: $ex'));
                                continue;
                            }

                            var rightExpr:Expr = try {
                                Context.parse(right, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse right side: $ex'));
                                continue;
                            }

                            var testSuccessExpr = doctestAdapter.generateTestSuccess(assertion);
                            var testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` is same instance right side.");

                            testMethodAssertions.push(macro {
                                var left = $leftExpr;
                                var right = $rightExpr;
                                if (left != right)
                                    $testSuccessExpr;
                                else
                                    $testFailedExpr;
                            });
                        }

                        // process "throws" assertion
                        else if (assertion.expression.indexOf(" throws ") > -1) {
                            var left = doctestLineFQ.substringBeforeLast(" throws ").trim();
                            var right = doctestLineFQ.substringAfterLast(" throws ").trim();

                            var leftExpr:Expr = try {
                                Context.parse(left, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse left side: $ex'));
                                continue;
                            }

                            var rightExpr:Expr = right == "nothing" ? macro "nothing": try {
                                Context.parse(right, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse right side: $ex'));
                                continue;
                            }

                            var testSuccessExpr = doctestAdapter.generateTestSuccess(assertion);
                            var testFailedExpr = doctestAdapter.generateTestFail(assertion, "Expected `$right` but was `$left`.");

                            testMethodAssertions.push(macro {
                                var left:Dynamic = "nothing";
                                try { $leftExpr; } catch (ex:Dynamic) left = ex;
                                var right:Dynamic;
                                try { right = $rightExpr; } catch (ex:Dynamic) right = "exception: " + ex;

                                if (hx.doctest.internal.DocTestUtils.deepEquals(left, right))
                                    $testSuccessExpr;
                                else
                                    $testFailedExpr;
                            });

                        // process comparison assertion
                        } else {
                            var doctestExpr = try {
                                Context.parse(doctestLineFQ, Context.currentPos());
                            } catch (ex:Dynamic) {
                                testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, 'Failed to parse assertion: $ex'));
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
                                            testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, "Assertion is missing one of the valid comparison operators: == != <= < > =>"));
                                            continue;
                                    }
                                    leftExpr = l;
                                    rightExpr = r;
                                default:
                                    testMethodAssertions.push(doctestAdapter.generateTestFail(assertion, "Assertion is missing one of the valid comparison operators: == != <= < > =>"));
                                    continue;
                            }

                            var comparisonExpr:Expr = null;
                            var testSuccessExpr = doctestAdapter.generateTestSuccess(assertion);
                            var testFailedExpr = null;
                            switch(comparator) {
                                case OpEq:
                                    comparisonExpr = macro hx.doctest.internal.DocTestUtils.deepEquals(left, right);
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` does not equal `$right`.");
                                case OpNotEq:
                                    comparisonExpr = macro !hx.doctest.internal.DocTestUtils.deepEquals(left, right);
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` equals `$right`.");
                                case OpLte:
                                    comparisonExpr = macro left <= right;
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` is not lower than or equal `$right`.");
                                case OpLt:
                                    comparisonExpr = macro left < right;
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` is not lower than `$right`.");
                                case OpGt:
                                    comparisonExpr = macro left > right;
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` is not greater than `$right`.");
                                case OpGte:
                                    comparisonExpr = macro left >= right;
                                    testFailedExpr = doctestAdapter.generateTestFail(assertion, "Left side `$left` is not greater than or equal `$right`.");
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

                        if (testMethodAssertions.length == 0)
                            continue;

                        // generate a new testMethod if required
                        if (testMethodAssertions.length == MAX_ASSERTIONS_PER_TEST_METHOD ||
                            Std.is(doctestAdapter, HaxeUnitDocTestAdapter) || Std.is(doctestAdapter, MUnitDocTestAdapter) // for haxe-unit and munit we create a new test-method per assertion
                        ) {
                            testMethodsCount++;
                            var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                            Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');
                            contextFields.push(doctestAdapter.generateTestMethod(testMethodName, 'Doc Testing [${src.filePath}] #${testMethodsCount}', testMethodAssertions));
                            testMethodAssertions = new Array<Expr>();
                        }

                    case CompilerConditionStart(condition):
                        if (condition.indexOf("#end") > -1)
                            continue;

                        var interp = new hscript.Interp();
                        var reg = new EReg("[a-zA-Z]\\w*", "gi");
                        var defines = haxe.macro.Context.getDefines();
                        var pos = 0;
                        while (reg.matchSub(condition, pos)) {
                            var pos2 = reg.matchedPos();
                            var define = reg.matched(0);
                            var defineValue = defines.get(define);
                            interp.variables.set(define, defineValue == null ? false : defineValue);
                            pos = reg.matchedPos().pos + reg.matchedPos().len;
                        }

                        try {
                            var result:Bool = interp.execute(parser.parseString(condition));
                            compilerConditions.push(result);
                        } catch (ex:Dynamic) {
                            Logger.log(ERROR, 'Failed to parse compiler condition "#if $condition" -> $ex');
                        }
                        continue;

                    case CompilerConditionElseIf(condition):
                        var interp = new hscript.Interp();
                        var reg = new EReg("[a-zA-Z]\\w*", "gi");
                        var defines = haxe.macro.Context.getDefines();
                        var pos = 0;
                        while (reg.matchSub(condition, pos)) {
                            var pos2 = reg.matchedPos();
                            var define = reg.matched(0);
                            var defineValue = defines.get(define);
                            interp.variables.set(define, defineValue == null ? false : defineValue);
                            pos = reg.matchedPos().pos + reg.matchedPos().len;
                        }

                        try {
                            var result:Bool = interp.execute(parser.parseString(condition));
                            if (compilerConditions.length > 0)
                                compilerConditions.pop();
                            compilerConditions.push(result);
                        } catch (ex:Dynamic) {
                            Logger.log(ERROR, 'Failed to parse compiler condition "#elseif $condition" -> $ex');
                        }
                        continue;

                    case CompilerConditionElse:
                        if (compilerConditions.length > 0) {
                            // flip the condition state
                            compilerConditions.push(!compilerConditions.pop());
                        }
                        continue;

                    case CompilerConditionEnd:
                        if (compilerConditions.length > 0)
                            compilerConditions.pop();
                        continue;
                }
            } // while (src.nextLine())

            // generate a new testMethod if required
            if (testMethodAssertions.length > 0) {
                testMethodsCount++;
                var testMethodName = 'test${src.haxeModuleName}_$testMethodsCount';
                Logger.log(DEBUG, '|--> Generating function "${testMethodName}()"...');
                contextFields.push(doctestAdapter.generateTestMethod(testMethodName, 'Doc Testing [${src.filePath}] #${testMethodsCount}', testMethodAssertions));
                testMethodAssertions = new Array<Expr>();
            }
        });

        doctestAdapter.onFinish(contextFields);

        Logger.log(INFO, 'Generated $totalAssertionsCount test assertions.');
        return contextFields;
    }

    static function getDocTestAdapter():DocTestAdapter {
        var clazz:ClassType = Context.getLocalClass().get();
        while (true) {
            if (clazz.module == "hx.doctest.DocTestRunner") return new TestrunnerDocTestAdapter();
            if (clazz.module == "haxe.unit.TestCase") return new HaxeUnitDocTestAdapter();
            #if tink_testrunner // to prevent "Type not found : tink.testrunner.Case" in TinkTestrunnerDocTestAdapter when tink_testrunner is not present
            if (clazz.module == "tink.testrunner.Suite") return new TinkTestrunnerDocTestAdapter();
            #end
            if (implementsInterface(clazz, "utest.ITest")) return new UTestDocTestAdapter();

            if (clazz.superClass == null) break;
            clazz = clazz.superClass.t.get();
        }

        // if no known super class was found, we expect it to be a MUnit test case
        return new MUnitDocTestAdapter();
    }

    static function implementsInterface(clazz:ClassType, interfaceName:String):Bool {
        for(iface in clazz.interfaces)
            if(iface.t.toString() == interfaceName)
                return true;
        return false;
    }
}
#end
