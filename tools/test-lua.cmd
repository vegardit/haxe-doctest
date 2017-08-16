@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\lua" rd /s /q "%CDP%dump\lua"
if exist "%CDP%..\target\lua" rd /s /q "%CDP%..\target\lua"

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
  -D luajit ^
  -lua "target\lua\TestRunner.lua"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
lua "%CDP%..\target\lua\TestRunner.lua"