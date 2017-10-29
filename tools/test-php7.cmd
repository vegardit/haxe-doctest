@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\php" rd /s /q "%CDP%dump\php"
if exist "%CDP%..\target\php7" rd /s /q "%CDP%..\target\php7"

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
  -D php7 ^
  -php "target\php7"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
%PHP7_HOME%\php "%CDP%..\target\php7\index.php"
