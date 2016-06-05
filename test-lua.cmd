@echo off
echo Cleaning...
if exist dump\lua rd /s /q dump\lua
if exist target\lua rd /s /q target\lua

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
-D luajit ^
-lua target/lua/TestRunner.lua || goto :eof

echo Testing...
lua53 target/lua/TestRunner.lua
