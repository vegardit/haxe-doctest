@echo off
REM Copyright (c) 2016-2018 Vegard IT GmbH, https://vegardit.com
REM SPDX-License-Identifier: Apache-2.0
REM Author: Sebastian Thomschke, Vegard IT GmbH

call %~dp0_test-prepare.cmd python

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
