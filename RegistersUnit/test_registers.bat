@echo off
REM Script para probar el módulo RegistersUnit con reg_out

echo ======================================
echo   Testing RegistersUnit Module
echo ======================================
echo.

echo Compiling RegistersUnit...
iverilog -g2012 -o registers_unit_test.out ^
    RegistersUnit.sv ^
    RegistersUnit_tb.sv

if %ERRORLEVEL% EQU 0 (
    echo    Compilation successful
    echo.
    echo Running simulation...
    echo.
    vvp registers_unit_test.out
    echo.
    echo ======================================
    echo   Test completed successfully!
    echo ======================================
    del registers_unit_test.out
    del RegistersUnit_tb.vcd
) else (
    echo    Compilation failed
    exit /b 1
)

pause
