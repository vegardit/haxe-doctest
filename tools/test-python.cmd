@echo off
set CDP=%~dp0

echo Cleaning...
if exist "%CDP%dump\python" rd /s /q "%CDP%dump\python"
if exist "%CDP%..\target\python" rd /s /q "%CDP%..\target\python"

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
  -python "target\python\TestRunner.py"
set rc=%errorlevel%
popd
if not %rc% == 0 exit /b %rc%

echo Testing...
python "%CDP%..\target\python\TestRunner.py"
