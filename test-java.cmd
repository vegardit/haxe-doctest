@echo off
echo Cleaning...
if exist dump\java rd /s /q dump\java
if exist target\java rd /s /q target\java

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr hxjava >NUL
if errorlevel 1 (
    echo Installing [hxjava]...
    haxelib install hxjava
)

echo Compiling...
haxe -main hx.doctest.TestRunner ^
-lib munit ^
-cp src ^
-cp test ^
-dce full ^
-debug ^
-D dump=pretty ^
-java target/java || goto :eof

echo Testing...
java -jar target/java/TestRunner-Debug.jar
