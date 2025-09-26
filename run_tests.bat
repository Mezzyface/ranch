@echo off
echo === Godot Console Test Runner ===
echo Running automated tests via Godot console...
echo.

REM Change to project directory
cd /d "%~dp0"

REM Run tests using Godot console executable with scene
"C:\Program Files\Godot\Godot_console.exe" --headless --scene test_console_scene.tscn

REM Capture exit code
set test_result=%errorlevel%

echo.
if %test_result% equ 0 (
    echo === ALL TESTS PASSED ===
    echo Exit code: %test_result%
) else (
    echo === TESTS FAILED ===
    echo Exit code: %test_result%
)

REM Pause to see results (comment out for CI/CD)
pause