#!/bin/bash
# Script para probar el módulo SevenSegTest

echo "======================================"
echo "  Testing SevenSegTest Module"
echo "======================================"
echo ""

echo "🔧 Compiling SevenSegTest..."
iverilog -g2012 -o seven_seg_test.out \
    ../SevenSegmentDisplay/SevenSegmentDisplay.sv \
    SevenSegTest.sv \
    SevenSegTest_tb.sv

if [ $? -eq 0 ]; then
    echo "   ✅ Compilation successful"
    echo ""
    echo "▶️  Running simulation..."
    echo ""
    vvp seven_seg_test.out
    echo ""
    echo "======================================"
    echo "  Test completed successfully! ✨"
    echo "======================================"
    rm -f seven_seg_test.out
else
    echo "   ❌ Compilation failed"
    exit 1
fi
