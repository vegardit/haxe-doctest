@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\neko" rd /s /q "%CDP%dump\neko"
if exist "%CDP%..\target\neko" rd /s /q "%CDP%..\target\neko"

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

echo Compiling...
pushd .
cd "%CDP%.."
haxe -main hx.doctest.TestRunner ^
  -lib munit ^
  -lib tink_testrunner ^
  -cp "src" ^
  -cp "test" ^
  -dce full ^
  -debug ^
  -D dump=pretty ^
  -neko "target\neko\TestRunner.n"
set rc=%errorlevel%
popd
if not %rc% == 0 goto :eof

echo Testing...
neko "%CDP%..\target\neko\TestRunner.n"
