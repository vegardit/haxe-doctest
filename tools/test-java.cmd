@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\java" rd /s /q "%CDP%dump\java"
if exist "%CDP%..\target\java" rd /s /q "%CDP%..\target\java"

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
pushd .
cd "%CDP%.."
haxe -main hx.doctest.TestRunner ^
  -lib munit ^
  -cp "src" ^
  -cp "test" ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -java "target\java"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
java -jar "%CDP%..\target\java\TestRunner-Debug.jar"
