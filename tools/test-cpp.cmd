@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\cpp" rd /s /q "%CDP%dump\cpp"
::if exist "%CDP%..\target\cpp" rd /s /q "%CDP%..\target\cpp"

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

haxelib list | findstr hxcpp >NUL
if errorlevel 1 (
    echo Installing [hxcpp]...
    haxelib install hxcpp
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
  -D HXCPP_CHECK_POINTER ^
  -D dump=pretty ^
  -cpp "target\cpp"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
"%CDP%..\target\cpp\TestRunner-Debug.exe"
