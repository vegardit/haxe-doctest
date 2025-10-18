@echo off
REM SPDX-FileCopyrightText: © Vegard IT GmbH (https://vegardit.com) and contributors
REM SPDX-FileContributor: Sebastian Thomschke, Vegard IT GmbH
REM SPDX-License-Identifier: Apache-2.0

pushd .

REM cd into project root
cd %~dp0..


if exist dump\%1 (
   echo Cleaning [dump\%1]...
   rd /s /q dump\%1
)
if exist target\%1 (
   echo Cleaning [target\%1]...
   rd /s /q target\%1
)
shift

REM install common libs
echo Checking required haxelibs...
for %%i in (hscript hx3compat hx4compat munit utest tink_testrunner) do (
   haxelib list | findstr %%i >NUL
   if errorlevel 1 (
      echo Installing [%%i]...
      haxelib install %%i
   )
)

haxelib list | findstr no-spoon >NUL
if errorlevel 1 (
  haxelib git no-spoon https://github.com/back2dos/no-spoon 7c98cbbdb22eb3751b55de197ab652fb4df74a1d
)

goto :eof

REM install additional libs
:iterate

   if "%~1"=="" goto :eof

   haxelib list | findstr %1 >NUL
   if errorlevel 1 (
      echo Installing [%1]...
      haxelib install %1
   )

   shift
   goto iterate
