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
-swf target/flash/TestRunner.swf || goto :eof

echo Testing...
flashplayer_21_sa_debug target/flash/TestRunner.swf
