@echo off
echo Cleaning...
if exist dump\hl rd /s /q dump\hl
if exist target\hl rd /s /q target\hl

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

echo Compiling and Testing...
haxe -main hx.doctest.TestRunner ^
-lib munit ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D dump=pretty ^
-D interp ^
-hl target/hl/TestRunner.hl
