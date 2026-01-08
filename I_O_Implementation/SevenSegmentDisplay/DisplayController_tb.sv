/**
 * Testbench para DisplayController
 * Prueba el controlador de 6 displays mostrando varios valores de 24 bits
 */
`timescale 1ns/1ps

module DisplayController_tb;

    logic [23:0] data_to_display;
    logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
    
    // Instanciar el módulo bajo prueba
    DisplayController dut (
        .data_to_display(data_to_display),
        .hex0(hex0),
        .hex1(hex1),
        .hex2(hex2),
        .hex3(hex3),
        .hex4(hex4),
        .hex5(hex5)
    );
    
    // Estímulos
    initial begin
        $display("====================================================");
        $display("  Display Controller Test (6 Displays, 24-bit)");
        $display("====================================================");
        $display("Data (24-bit)   | HEX5 HEX4 HEX3 HEX2 HEX1 HEX0");
        $display("----------------|------------------------------");
        
        // Caso 1: 0x000000
        data_to_display = 24'h000000;
        #10;
        $display("0x%h | %b %b %b %b %b %b", 
                 data_to_display, hex5, hex4, hex3, hex2, hex1, hex0);
        
        // Caso 2: 0x123456
        data_to_display = 24'h123456;
        #10;
        $display("0x%h | %b %b %b %b %b %b", 
                 data_to_display, hex5, hex4, hex3, hex2, hex1, hex0);
        
        // Caso 3: 0xABCDEF
        data_to_display = 24'hABCDEF;
        #10;
        $display("0x%h | %b %b %b %b %b %b", 
                 data_to_display, hex5, hex4, hex3, hex2, hex1, hex0);
        
        // Caso 4: 0xFFFFFF
        data_to_display = 24'hFFFFFF;
        #10;
        $display("0x%h | %b %b %b %b %b %b", 
                 data_to_display, hex5, hex4, hex3, hex2, hex1, hex0);
        
        // Caso 5: 0xDEADBE
        data_to_display = 24'hDEADBE;
        #10;
        $display("0x%h | %b %b %b %b %b %b", 
                 data_to_display, hex5, hex4, hex3, hex2, hex1, hex0);
        
        $display("====================================================");
        $display("✅ Test completado");
        $display("====================================================");
        
        $finish;
    end
    
    // Generar archivo VCD
    initial begin
        $dumpfile("I_O_Implementation/SevenSegmentDisplay/DisplayController_tb.vcd");
        $dumpvars(0, DisplayController_tb);
    end

endmodule
