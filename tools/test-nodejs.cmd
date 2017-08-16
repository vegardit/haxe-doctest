@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\js" rd /s /q "%CDP%dump\js"
if exist "%CDP%..\target\js" rd /s /q "%CDP%..\target\js"

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
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
  -D nodejs ^
  -js "target\js\TestRunner.js"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
node "%CDP%..\target\js\TestRunner.js"
