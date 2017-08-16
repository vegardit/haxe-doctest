@echo off
echo Cleaning...
if exist dump\python rd /s /q dump\python
if exist target\python rd /s /q target\python

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
-python target\python\TestRunner.py || goto :eof

echo Testing...
python target\python\TestRunner.py
