@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\hl" rd /s /q "%CDP%dump\hl"
if exist "%CDP%..\target\hl" rd /s /q "%CDP%..\target\hl"

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

echo Compiling and Testing...
pushd .
cd "%CDP%.."
haxe -main hx.doctest.TestRunner ^
  -lib munit ^
  -cp "src" ^
  -cp "test" ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -hl "target\hl\TestRunner.hl"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

hl "%CDP%..\target\hl\TestRunner.hl"