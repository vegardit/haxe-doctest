@echo off
echo Cleaning...
if exist dump\csharp rd /s /q dump\csharp
if exist target\csharp rd /s /q target\csharp

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr hxcs >NUL
if errorlevel 1 (
    echo Installing [hxcs]...
    haxelib install hxcs
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
-lib munit ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D dump=pretty ^
-cs target\csharp || goto :eof

echo Testing...
mono target\csharp\bin\TestRunner-Debug.exe
