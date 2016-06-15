@echo off
echo Cleaning...
if exist dump\cpp rd /s /q dump\cpp

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr hxcpp >NUL
if errorlevel 1 (
    echo Installing [hxcpp]...
    haxelib install hxcpp
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
-lib munit ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D HXCPP_CHECK_POINTER ^
-D dump=pretty ^
-cpp target\cpp || goto :eof

echo Testing...
target\cpp\TestRunner-Debug.exe
