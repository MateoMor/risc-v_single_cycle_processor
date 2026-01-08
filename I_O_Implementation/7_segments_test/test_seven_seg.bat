@echo off
REM Script para probar el módulo SevenSegTest

echo ======================================
echo   Testing SevenSegTest Module
echo ======================================
echo.

echo Compiling SevenSegTest...
iverilog -g2012 -o seven_seg_test.out ^
    ..\SevenSegmentDisplay\DisplayController.sv ^
    ..\SevenSegmentDisplay\SevenSegmentDisplay.sv ^
    SevenSegTest.sv ^
    SevenSegTest_tb.sv

if %ERRORLEVEL% EQU 0 (
    echo    Compilation successful
    echo.
    echo Running simulation...
    echo.
    vvp seven_seg_test.out
    echo.
    echo ======================================
    echo   Test completed successfully!
    echo ======================================
    del seven_seg_test.out
) else (
    echo    Compilation failed
    exit /b 1
)

pause
