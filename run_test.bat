@echo off
echo 🔨 Compiling RISC-V Single Cycle Processor...

iverilog -g2012 -o riscv.out ^
    RiscV_SingleCycle.sv ^
    RiscV_SingleCycle_tb.sv ^
    ProgramCounter\ProgramCounter.sv ^
    InstructionMemory\InstructionMemory.sv ^
    ControlUnit\ControlUnit.sv ^
    RegistersUnit\RegistersUnit.sv ^
    ImmGen\ImmGen.sv ^
    ALU\ALU.sv ^
    BranchUnit\BranchUnit.sv ^
    DataMemory\DataMemory.sv ^
    muxs\ALUA.sv ^
    muxs\ALUB.sv ^
    muxs\NextPC.sv ^
    muxs\RUDataWr.sv

if %errorlevel% equ 0 (
    echo ✅ Compilation successful
    echo ▶️  Running simulation...
    echo.
    vvp riscv.out
) else (
    echo ❌ Compilation failed
    pause
    exit /b 1
)

pause