# haxe-doctest - Haxedoc based unit testing.

1. [What is it?](#what-is-it)
1. [Declaring test assertions](#declaring-test-assertions)
1. [Why to use doctests?](#why-doctests)
1. [Using doctest with MUnit](#doctest-with-munit)
1. [Using doctest with Haxe Unit](#doctest-with-haxeunit)
1. [Using doctest with FlashDevelop](#doctest-testrunner)
1. [Using the latest code](#latest)
1. [License](#license)


<a name="what-is-it"></a>What is it?
---------------------

A [haxelib](http://lib.haxe.org/documentation/using-haxelib/) inspired by
Python's [doctest](https://docs.python.org/2/library/doctest.html) command that generates 
unit tests based on assertions specified within the source code.

`haxe-doctest` supports the generation of test cases for [Haxe Unit](http://haxe.org/manual/std-unit-testing.html), [MUnit](https://github.com/massiveinteractive/MassiveUnit), and it's own [test runner](#doctest-testrunner) which is recommended for efficient testing from within FlashDevelop.

    
<a name="declaring-test-assertions"></a>Declaring test assertions
---------------------

Doctest assertions are written as part of the source code documentation and are
identified by three leading right angle brackets `>>>` before the assertion.

```haxe
class MyTools {
    
    /**
     * <pre><code>
     * >>> MyTools.isValidName(null)   == false
     * >>> MyTools.isValidName("")     == false
     * >>> MyTools.isValidName("John") == true
     * </code></pre>
     */
    public static function isValidName(str:String):Bool {
        return str != null && str.length > 0;
    }
}
```

The test expression and the expected value must be separated by the equality operator `==`. Other comparison operators are not supported but can be used as part of the test expression itself as outlined in the following example:

```haxe
class MyObject {

    /**
     * <pre><code>
     * >>> new MyObject("ab").length()  > 1    == true
     * >>> new MyObject("ab").length()  <= 2   == true
     * >>> new MyObject("abc").length() >= 4   == false
     * </code></pre>
     */
    public function length(str:String):Int {
        return str == null ? 0 : str.length;
    }
    
    var data:String;
    
    public function new(data:String) {
        this.data = data;
    }
}
```


<a name="why-doctests"></a>Why to use doctests?
---------------------

1. doctests supports super fast test-driven development: First you write your method header, 
   then the in-place documentation including your test assertions defining the expected behavior
   and then implement until all your defined tests pass.

   No need to create separate test classes with individual test methods.
   Implementing and testing happens at the same code location.
   
1. For users of your code, the doctest assertions act as method documentation and code examples.

1. Since doctest actually tests your documentation, your documentation always represents 
   the actual behaviour of the method implementation.


<a name="doctest-with-haxeunit"></a>Using doctest with Haxe Unit
---------------------

Annotate a class extending `haxe.unit.TestCase` with `@:build(hx.doctest.DocTestGenerator.generateDocTests())`. The doctest assertions from your sourcecode will then be added as test methods to this class.

```haxe
@:build(hx.doctest.DocTestGenerator.generateDocTests())
class MyHaxeUnitTest extends haxe.unit.TestCase {

    public static function main() {
        var runner = new haxe.unit.TestRunner();
        runner.add(new MyHaxeUnitTest());
        runner.run();
    }

    function new() {
        super();
    }
}
```


<a name="doctest-with-munit"></a>Using doctest with MUnit
---------------------

Annotate a test class with `@:build(hx.doctest.DocTestGenerator.generateDocTests())`.
The doctest assertions from your sourcecode will then be added as test methods to this class.

```haxe
@:build(hx.doctest.DocTestGenerator.generateDocTests())
class MyMUnitDocTests {
    public function new() { }
}
```

Then add the test class to a testsuite
```haxe
class MyMUnitDocTestSuite extends massive.munit.TestSuite {
    public static function main() {
        var client = new massive.munit.RichPrintClient();
        var runner = new massive.munit.TestRunner(client);
        runner.run([MyMUnitDocTestSuite]);
    }
    
    public function new() {
        super();
        add(MyMUnitDocTests);
    }
}
```


<a name="doctest-testrunner"></a>Using the doctest Testrunner
---------------------

doctest also comes with it's own Testrunner which is recommended for local testing as it generates console output that is parseable by [FlashDevelop](http://www.flashdevelop.org/). When executed from within FlashDevelop, test failures will be displayed in the result panel as clickable errors that directly navigate your to the location in your source code.

To use it, annotate a class extending `hx.doctest.DocTestRunner`  with `@:build(hx.doctest.DocTestGenerator.generateDocTests())`.
The doctest assertions from your sourcecode will then be added as test methods to this class.

```haxe
@:build(hx.doctest.DocTestGenerator.generateDocTests())
class MyDocTestRunner extends hx.doctest.DocTestRunner {

    public static function main() {
        var runner = new DocTestTest();
        runner.runAndExit();
    }
    
    function new() { super(); }
}
```

To integrate this with FlashDevelop, create a batch file in your project root folder, e.g. called `test-docs.cmd` containing:
```bat
echo Compiling...
haxe -main mypackage.MyDocTestRunner ^
-cp src ^
-cp test ^
-neko target/neko/MyDocTestRunner.n || goto :eof

echo Testing...
neko target/neko/TestRunner.n
```

In FlashDevelop create a new macro in the macro editor (which is reachable via the menu **Macros -> Edit Macros...**) containing 
the following statements.
```bat
InvokeMenuItem|FileMenu.Save
RunProcessCaptured|$(SystemDir)\cmd.exe;/c cd $(ProjectDir) & $(ProjectDir)\test-docs.cmd
```

Then assign the macro a short cut, e.g. [F4]. 

Now you can write your methods, document their behavior in the doc and by pressing [F4] your changes are saved and the doctests assertions will be tested. Errors will showup as navigable events in the FlashDevelop's result panel.

   
<a name="latest"></a>Using the latest code
---------------------

1. check-out the trunk
    ```
    haxelib git haxe-doctest https://github.com/vegardit/haxe-doctest.git src
    ```

    or with Subversion
    ```
    svn checkout https://github.com/vegardit/haxe-doctest/trunk D:\haxe-projects\haxe-doctest
    ```

2. register the development release with haxe
    ```
    haxelib dev haxe-doctest D:\haxe-projects\haxe-doctest
    ```

3. use in your Haxe project
  * for [OpenFL](http://www.openfl.org/)/[Lime](https://github.com/openfl/lime) projects add `<haxelib name="haxe-doctest" />` to your [project.xml](http://www.openfl.org/documentation/projects/project-files/xml-format/)
  * for free-style projects add `-lib haxe-doctest`  to `your *.hxml` file or as command line option when running the [Haxe compiler](http://haxe.org/manual/compiler-usage.html)


<a name="license"></a>License
---------------------

All files are released under the [MIT license](https://github.com/vegardit/haxe-strings/blob/master/LICENSE.txt).
