@echo off
REM Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
REM SPDX-License-Identifier: Apache-2.0
REM Author: Sebastian Thomschke, Vegard IT GmbH

pushd .

REM cd into project root
cd %~dp0..

echo Cleaning...
if exist dump\python rd /s /q dump\python
if exist target\python rd /s /q target\python

haxelib list | findstr hx3compat >NUL
if errorlevel 1 (
    echo Installing [hx3compat]...
    haxelib install hx3compat
)

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr tink_testrunner >NUL
if errorlevel 1 (
    echo Installing [tink_testrunner]...
    haxelib install tink_testrunner
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
  -lib hx3compat ^
  -lib munit ^
  -lib tink_testrunner ^
  -cp src ^
  -cp test ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -python target\python\TestRunner.py
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
python "%~dp0..\target\python\TestRunner.py"
