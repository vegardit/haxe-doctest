@echo off
REM Copyright (c) 2016-2017 Vegard IT GmbH, http://vegardit.com
REM SPDX-License-Identifier: Apache-2.0
REM Author: Sebastian Thomschke, Vegard IT GmbH

pushd .

REM cd into project root
cd %~dp0..

echo Cleaning...
if exist dump\flash rd /s /q dump\flash
if exist target\flash rd /s /q target\flash

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
  -D no-swf-compress ^
  -D swf-script-timeout=180 ^
  -swf-version 11.5 ^
  -swf target\flash\TestRunner.swf
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

REM enable Flash logging
(
    echo ErrorReportingEnable=1
    echo TraceOutputFileEnable=1
) > "%HOME%\mm.cfg"

echo Testing...
flashplayer_27_sa_debug "%~dp0..\target\flash\TestRunner.swf"
set exitCode=%errorlevel%

REM printing log file
type "%HOME%\AppData\Roaming\Macromedia\Flash Player\Logs\flashlog.txt"

exit /b %exitCode%
