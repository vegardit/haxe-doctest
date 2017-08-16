@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\php" rd /s /q "%CDP%dump\php"
if exist "%CDP%..\target\php" rd /s /q "%CDP%..\target\php"

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
  -php "target\php"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
%PHP5_HOME%\php "%CDP%..\target\php\index.php"
