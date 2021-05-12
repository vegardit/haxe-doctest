# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [Unreleased]

## [3.1.5] - 2021-05-12

### Changed
- make hx.doctest.internal.Logger.log function dynamic


## [3.1.4] - 2021-05-11

### Changed
- Improved logging on HL


## [3.1.3] - 2021-05-07

### Changed
- Improved error reporting


## [3.1.2] - 2021-05-06

### Fixed
- "Warning: Std.is is deprecated. Use Std.isOfType instead." on Haxe 4.2


## [3.1.1] - 2020-05-31

### Fixed
- compiler conditionals are sometimes interpreted wrong
- [Issue #11](https://github.com/vegardit/haxe-doctest/issues/11) Error `Unknown identifier : assertion` on Haxe 4.2-dev


## [3.1.0] - 2020-04-20

### Added
- typedef `hx.doctest.PosInfosExt`
- class `hx.doctest.DocTestRunner.DocTestResult`
- property `hx.doctest.DocTestRunner.DocTestResults#tests:Array<DocTestResult>`
- property `hx.doctest.DocTestRunner.DocTestResults#testsPassed:Int`
- property `hx.doctest.DocTestRunner.DocTestResults#testsFailed:Int`

### Changed
- deprecated method `hx.doctest.DocTestRunner.DocTestResults#getSuccessCount()`
- deprecated method `hx.doctest.DocTestRunner.DocTestResults#getFailureCount()`

### Fixed
- wrong character position is reported on test failure


## [3.0.0] - 2020-04-18

### Changed
- minimum required Haxe version is now 4.x

### Fixed
- [compiler conditionals](https://haxe.org/manual/lf-condition-compilation.html) not respected properly when generating/testing doctest assertions


## [2.0.1] - 2019-09-20

### Fixed
- fixed method signature of DocTestRunner#assertMax()


## [2.0.0] - 2019-05-19

### Added
- new comparisons operators === and !== to assert reference equality/inequality
- multiline support for assertions

### Changed
- comparison operators != and == now perform deep comparison of objects instead of reference equality/inequality checks
- the signature of the DocTestGenerator#generateDocTests() has been changed to use the DocTestGeneratorConfig typedef for it's arguments


## [1.3.0] - 2019-04-26

### Added
- support for executing doctests with [utest](https://github.com/fponticelli/utest)


## [1.2.0] - 2018-12-02

### Added
- respect [compiler conditionals](https://haxe.org/manual/lf-condition-compilation.html) when generating/testing doctest assertions
- DocTestRunner#assertInRange()
- DocTestRunner#assertMax()
- DocTestRunner#assertMin()

### Changed
- raise minimum requirement to Haxe 3.4.x


## [1.1.4] - 2018-11-27

### Added
- DocTestRunner#exit()


## [1.1.3] - 2018-04-14

### Changed
- replaced license header by "SPDX-License-Identifier: Apache-2.0"
- improved regex matching
- improved exception assertion parsing


## [1.1.2] - 2017-10-16

### Fixed
- "Class<haxe.macro.Context> has no field currentPos" on some targets


## [1.1.1] - 2017-10-16

### Fixed
- "Type not found : tink.testrunner.Case" when tink_testrunner is not present


## [1.1.0] - 2017-09-14

### Added
- support for executing doctests with [Tink Testrunner](https://github.com/haxetink/tink_testrunner)


## [1.0.9] - 2017-08-23

### Added
- Allow pattern matching with 'throws' assertions


## [1.0.8] - 2017-08-19

### Added
- DocTestRunner.runAndExit() now also exists with a proper exit code on Flash
- improved support for builds with Travis/travix

### Fixed
- "TypeError: undefined is not an object (evaluating 'process.release.name')" when running with phantom.js on Travis


## [1.0.7] - 2017-08-16

### Added
- DocTestGenerator.generateDocTests() now automatically adds @:keep to the test class to prevent test methods being DCE-ed

### Changed
- test methods are sorted by name before executed


## [1.0.6] - 2017-08-08

### Fixed
- Workaround for Haxe 3.x Lua target bug (using 'continue' in for-loop results in: 'until' expected (to close 'repeat' at line 1862) near 'end')


## [1.0.5] - 2017-05-08

### Added
- logging stacktraces of unexpected exceptions thrown by test assertions


## [1.0.4] - 2017-04-19

### Fixed
- Eof when scanning Haxe files without package declaration [#1](https://github.com/vegardit/haxe-doctest/issues/1)


## [1.0.3] - 2017-02-23

### Added
- Support for Node.js


## [1.0.2] - 2017-01-02

### Added
- DocTestRunner#assertFalse()
- DocTestRunner#assertNotEquals()

### Changed
- DocTestUtils#equals() now handles EnumValues


## [1.0.1] - 2016-07-17

### Fixed
- "Type not found" in some cases


## [1.0.0] - 2016-07-09

### Added
- the doc-test identifier string is now configurable

### Changed
- changed license from MIT to Apache License 2.0

### Fixed
- out of memory error when parsing very large files


## [0.3.2] - 2016-06-22

### Changed
- improved Lua support


## [0.3.1] - 2016-06-20

### Changed
- improved parsing


## [0.3.0] - 2016-06-17

### Added
- added support for other comparison operators: <, >, !=, <=, >=
- added support for asserting exceptions


## [0.2.3] - 2016-06-16

### Changed
- improved error reporting


## [0.2.2] - 2016-06-10

### Fixed
- reduced maximum number of tests per generated test method to avoid "code too large" error in javac
- ReferenceError: Can't find variable: __js__


## [0.2.1] - 2016-06-10

### Fixed
- comparing anonymous structures on C# results in System.NullReferenceException


## [0.2.0] - 2016-06-10

### Added
- support for comparing anonymous structures, e.g. `{ cats: 4, dogs: 3 } == { cats: 4, dogs: 3 }`
- better error reporting of syntax errors in doctest assertions
- added `expectedMinNumberOfTests` argument to `DocTestRunner.run/runAndExit` methods


## 0.1.0 - 2016-06-05

### Added
- Initial release
