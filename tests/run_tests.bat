@echo off
REM Simplified test runner wrapper (delegates to PowerShell script for timeout supervision)
REM Usage: tests\run_tests.bat [timeoutSeconds]

setlocal
set ARG_TIMEOUT=%1
set ARG_FILTER=%2
set ARG_PER_TEST_MS=%3
if "%ARG_TIMEOUT%"=="" set ARG_TIMEOUT=300
if "%ARG_FILTER%"=="" set ARG_FILTER=

REM Change to project root
cd /d "%~dp0.."

echo === Godot Automated Test Runner ===
echo Timeout (s): %ARG_TIMEOUT%
if not "%GODOT_EXE%"=="" echo GODOT_EXE: %GODOT_EXE%
if "%ARG_FILTER%"=="" (echo Test Filter: <none>) else (echo Test Filter: %ARG_FILTER%)
if "%ARG_PER_TEST_MS%"=="" (echo Per-Test Timeout (ms): <default>) else (echo Per-Test Timeout (ms): %ARG_PER_TEST_MS%)
echo (Debug) Raw Args: timeout=%ARG_TIMEOUT% filter="%ARG_FILTER%" perTest=%ARG_PER_TEST_MS%
echo.

set PS_ARGS=-TimeoutSeconds %ARG_TIMEOUT% -TestFilter "%ARG_FILTER%"
if not "%ARG_PER_TEST_MS%"=="" set PS_ARGS=%PS_ARGS% -PerTestTimeoutMs %ARG_PER_TEST_MS%
if not "%GODOT_EXE%"=="" set PS_ARGS=%PS_ARGS% -GodotExe "%GODOT_EXE%"
echo PowerShell Args: %PS_ARGS%

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tests\run_tests.ps1 %PS_ARGS%
set test_result=%errorlevel%
echo.
if %test_result% equ 0 (
    echo === ALL TESTS PASSED ===
) else if %test_result% equ 99 (
    echo === TEST RUN TIMEOUT (99) ===
) else if %test_result% equ 2 (
    echo === GODOT EXECUTABLE NOT FOUND / START FAILURE (2) ===
) else if %test_result% equ 130 (
    echo === TEST RUN INTERRUPTED (Ctrl+C) (130) ===
) else (
    echo === TESTS FAILED (exit %test_result%) ===
)
echo Exit code: %test_result%

pause
endlocal
