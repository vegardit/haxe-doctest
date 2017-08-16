@echo off
echo Cleaning...
if exist dump\flash rd /s /q dump\flash
if exist target\flash rd /s /q target\flash

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D dump=pretty ^
-swf-version 11.5 ^
-swf target/flash/TestRunner.swf || goto :eof

REM enable Flash logging
(
    echo ErrorReportingEnable=1
    echo TraceOutputFileEnable=1
) > "%HOME%\mm.cfg"

echo Testing...
flashplayer_24_sa_debug target/flash/TestRunner.swf
set exitCode=%errorlevel%

REM printing log file
type "%HOME%\AppData\Roaming\Macromedia\Flash Player\Logs\flashlog.txt"

exit /b %exitCode%
