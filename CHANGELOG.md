# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com/).

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
