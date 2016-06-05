@echo off
echo Cleaning...
if exist dump\js rd /s /q dump\js
if exist target\js rd /s /q target\js

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
-lib munit ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D dump=pretty ^
-js target\js\TestRunner.js || goto :eof

echo Testing...
phantomjs target\js\TestRunner.js
