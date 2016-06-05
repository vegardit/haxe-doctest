@echo off
echo Cleaning...
if exist dump\php rd /s /q dump\php
if exist target\php rd /s /q target\php

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
-php target\php || goto :eof

echo Testing...
php target\php\index.php
