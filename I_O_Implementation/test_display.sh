#!/bin/bash
# Script para probar el RISC-V Processor con FPGA y displays

echo "======================================"
echo "  Testing RISC-V FPGA Implementation"
echo "======================================"
echo ""

echo "🔧 Compiling RISC-V Processor with FPGA wrapper..."
iverilog -g2012 -o riscv_fpga_test.out \
    ProgramCounter/ProgramCounter.sv \
    InstructionMemory/InstructionMemory.sv \
    ControlUnit/ControlUnit.sv \
    RegistersUnit/RegistersUnit.sv \
    ImmGen/ImmGen.sv \
    muxs/ALUA.sv \
    muxs/ALUB.sv \
    muxs/RUDataWr.sv \
    muxs/NextPC.sv \
    ALU/ALU.sv \
    DataMemory/DataMemory.sv \
    BranchUnit/BranchUnit.sv \
    RiscV_SingleCycle.sv \
    I_O_Implementation/SevenSegmentDisplay/SevenSegmentDisplay.sv \
    I_O_Implementation/SevenSegmentDisplay/DisplayController.sv \
    I_O_Implementation/RiscV_SingleCycle_FPGA.sv \
    I_O_Implementation/RiscV_SingleCycle_FPGA_tb.sv

if [ $? -eq 0 ]; then
    echo "   ✅ Compilation successful"
    echo ""
    echo "▶️  Running simulation..."
    vvp riscv_fpga_test.out
    echo ""
    echo "======================================"
    echo "  Test completed successfully! ✨"
    echo "======================================"
    rm -f riscv_fpga_test.out
else
    echo "   ❌ Compilation failed"
    exit 1
fi
