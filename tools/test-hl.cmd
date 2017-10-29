@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\hl" rd /s /q "%CDP%dump\hl"
if exist "%CDP%..\target\hl" rd /s /q "%CDP%..\target\hl"

haxelib list | findstr hx3compat >NUL
if errorlevel 1 (
    echo Installing [hx3compat]...
    haxelib install hx3compat
)

haxelib list | findstr munit >NUL
if errorlevel 1 (
    echo Installing [munit]...
    haxelib install munit
)

haxelib list | findstr tink_testrunner >NUL
if errorlevel 1 (
    echo Installing [tink_testrunner]...
    haxelib install tink_testrunner
)

echo Compiling and Testing...
pushd .
cd "%CDP%.."
haxe -main hx.doctest.TestRunner ^
  -lib hx3compat ^
  -lib munit ^
  -lib tink_testrunner ^
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
