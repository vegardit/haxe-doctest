@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\cs" rd /s /q "%CDP%dump\cs"
if exist "%CDP%..\target\cs" rd /s /q "%CDP%..\target\cs"

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

haxelib list | findstr hxcs >NUL
if errorlevel 1 (
    echo Installing [hxcs]...
    haxelib install hxcs
)

echo Compiling...
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
  -cs "%CDP%..\target\cs"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
mono "%CDP%..\target\cs\bin\TestRunner-Debug.exe"
