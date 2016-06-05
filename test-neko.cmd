@echo off
echo Cleaning...
if exist dump\neko rd /s /q dump\neko
if exist target\neko rd /s /q target\neko

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
-neko target/neko/TestRunner.n || goto :eof

echo Testing...
neko target/neko/TestRunner.n
