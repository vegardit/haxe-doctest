# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com/).

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
