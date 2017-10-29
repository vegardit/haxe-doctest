@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\flash" rd /s /q "%CDP%dump\flash"
if exist "%CDP%..\target\flash" rd /s /q "%CDP%..\target\flash"

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
pushd .
cd "%CDP%.."
haxe -main hx.doctest.TestRunner ^
  -lib hx3compat ^
  -lib munit ^
  -lib tink_testrunner ^
  -cp "src" ^
  -cp "test" ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -swf-version 11.5 ^
  -swf "target\flash\TestRunner.swf"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

REM enable Flash logging
(
    echo ErrorReportingEnable=1
    echo TraceOutputFileEnable=1
) > "%HOME%\mm.cfg"

echo Testing...
flashplayer_24_sa_debug "%CDP%..\target\flash\TestRunner.swf"
set exitCode=%errorlevel%

REM printing log file
type "%HOME%\AppData\Roaming\Macromedia\Flash Player\Logs\flashlog.txt"

exit /b %exitCode%
