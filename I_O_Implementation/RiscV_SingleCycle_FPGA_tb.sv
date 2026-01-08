`timescale 1ns/1ps

module RiscV_SingleCycle_FPGA_tb;

    // Señales del testbench
    logic clk;
    logic reset;
    logic [4:0] SW;
    
    // Salidas de los displays
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    // Debug ports
    logic [31:0] debug_selected_register;
    
    // Instancia del DUT (Device Under Test)
    RiscV_SingleCycle_FPGA #(
        .IMEM_SIZE(128),
        .PROGRAM_FILE("test_programs/program.hex")
    ) dut (
        .clk(clk),
        .reset(reset),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5),
        .debug_selected_register(debug_selected_register)
    );
    
    // Generador de reloj (50 MHz = 20ns período)
    initial clk = 0;
    always #10 clk = ~clk;
    
    // Variables de monitoreo
    integer cycle_count;
    integer error_count;
    
    // Función para decodificar displays de 7 segmentos a hexadecimal
    // Tabla debe coincidir exactamente con SevenSegmentDisplay.sv
    function automatic logic [3:0] decode_7seg;
        input logic [6:0] seg;
        begin
            case(seg)
                7'b1111110: decode_7seg = 4'h0;  // 0
                7'b1111001: decode_7seg = 4'h1;  // 1
                7'b0100100: decode_7seg = 4'h2;  // 2
                7'b0110000: decode_7seg = 4'h3;  // 3
                7'b0011001: decode_7seg = 4'h4;  // 4
                7'b0010010: decode_7seg = 4'h5;  // 5
                7'b0000010: decode_7seg = 4'h6;  // 6
                7'b1111000: decode_7seg = 4'h7;  // 7
                7'b0000000: decode_7seg = 4'h8;  // 8
                7'b0010000: decode_7seg = 4'h9;  // 9
                7'b0001000: decode_7seg = 4'hA;  // A
                7'b0000011: decode_7seg = 4'hB;  // b
                7'b1000110: decode_7seg = 4'hC;  // C
                7'b0100001: decode_7seg = 4'hD;  // d
                7'b0000110: decode_7seg = 4'hE;  // E
                7'b0001110: decode_7seg = 4'hF;  // F
                default:    decode_7seg = 4'hX;  // Desconocido/Indefinido
            endcase
        end
    endfunction
    
    // Función para obtener el valor de 24 bits mostrado en los displays
    function automatic logic [23:0] get_display_value;
        begin
            get_display_value = {
                decode_7seg(HEX5),
                decode_7seg(HEX4),
                decode_7seg(HEX3),
                decode_7seg(HEX2),
                decode_7seg(HEX1),
                decode_7seg(HEX0)
            };
        end
    endfunction
    
    // Task para imprimir el estado de los displays
    task print_displays;
        input string label;
        logic [23:0] display_val;
        begin
            display_val = get_display_value();
            $display("\n========== %s ==========", label);
            $display("Cycle: %0d | Time: %0t", cycle_count, $time);
            $display("SW[4:0] = %05b (Register x%0d)", SW, SW);
            $display("Display Value = 0x%06h", display_val);
            $display("HEX5=%07b HEX4=%07b HEX3=%07b", HEX5, HEX4, HEX3);
            $display("HEX2=%07b HEX1=%07b HEX0=%07b", HEX2, HEX1, HEX0);
        end
    endtask
    
    // Task para verificar el valor mostrado en los displays
    task check_display;
        input logic [4:0] reg_num;
        input logic [23:0] expected_value;
        input string description;
        logic [23:0] actual_value;
        begin
            actual_value = get_display_value();
            if (actual_value === expected_value) begin
                $display("✅ %s: Display shows 0x%06h for register x%0d", 
                         description, actual_value, reg_num);
            end else begin
                $error("❌ %s: Display shows 0x%06h, expected 0x%06h for register x%0d",
                       description, actual_value, expected_value, reg_num);
                error_count = error_count + 1;
            end
        end
    endtask
    
    // Task para verificar debug_selected_register
    task check_selected_register;
        input logic [4:0] reg_num;
        input logic [31:0] expected_value;
        input string description;
        begin
            if (debug_selected_register === expected_value) begin
                $display("✅ %s: selected_register = 0x%08h for register x%0d", 
                         description, debug_selected_register, reg_num);
            end else begin
                $error("❌ %s: selected_register = 0x%08h, expected 0x%08h for register x%0d",
                       description, debug_selected_register, expected_value, reg_num);
                error_count = error_count + 1;
            end
        end
    endtask
    
    // Secuencia principal del test
    initial begin
        $dumpfile("riscv_fpga_tb.vcd");
        $dumpvars(0, RiscV_SingleCycle_FPGA_tb);
        
        // Inicialización
        cycle_count = 0;
        error_count = 0;
        SW = 5'b00000;
        
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════╗");
        $display("║   RISC-V Single Cycle FPGA - Display Testbench           ║");
        $display("╚═══════════════════════════════════════════════════════════╝");
        
        // Reset inicial
        $display("\n🔄 Applying reset...");
        reset = 1;
        repeat(3) @(posedge clk);
        reset = 0;
        
        // Ejecutar el programa por varios ciclos
        $display("\n📊 Executing program...");
        repeat(15) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
        end
        
        $display("\n⏸️  Program execution completed (%0d cycles)", cycle_count);
        
        // ========== Prueba de Visualización de Registros ==========
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════╗");
        $display("║           Testing Register Display Selection             ║");
        $display("╚═══════════════════════════════════════════════════════════╝");
        
        // Esperar un ciclo para que se estabilicen las señales
        @(posedge clk);
        
        // Test 1: Mostrar x0 (siempre debe ser 0)
        SW = 5'd0;
        #50; // Esperar tiempo de propagación
        print_displays("Register x0 (should be 0x000000)");
        check_display(0, 24'h000000, "x0 register");
        check_selected_register(0, 32'h00000000, "x0 via selected_register");
        
        // Test 2: Mostrar x8 (debería ser 4)
        SW = 5'd8;
        #50;
        print_displays("Register x8 (should be 0x000004)");
        check_display(8, 24'h000004, "x8 register");
        check_selected_register(8, 32'h00000004, "x8 via selected_register");
        
        // Test 3: Mostrar x9 (debería ser 12 = 0xC)
        SW = 5'd9;
        #50;
        print_displays("Register x9 (should be 0x00000C)");
        check_display(9, 24'h00000C, "x9 register");
        check_selected_register(9, 32'h0000000C, "x9 via selected_register");
        
        // Test 4: Mostrar x18 (debería ser 16 = 0x10)
        SW = 5'd18;
        #50;
        print_displays("Register x18 (should be 0x000010)");
        check_display(18, 24'h000010, "x18 register");
        check_selected_register(18, 32'h00000010, "x18 via selected_register");
        
        // Test 5: Mostrar x10 (debería ser 16 = 0x10)
        SW = 5'd10;
        #50;
        print_displays("Register x10 (should be 0x000010)");
        check_display(10, 24'h000010, "x10 register");
        check_selected_register(10, 32'h00000010, "x10 via selected_register");
        
        // Test 6: Mostrar x13 (debería ser 10 = 0xA)
        SW = 5'd13;
        #50;
        print_displays("Register x13 (should be 0x00000A)");
        check_display(13, 24'h00000A, "x13 register");
        check_selected_register(13, 32'h0000000A, "x13 via selected_register");
        
        // Test 7: Mostrar x11 (debería ser 4)
        SW = 5'd11;
        #50;
        print_displays("Register x11 (should be 0x000004)");
        check_display(11, 24'h000004, "x11 register");
        check_selected_register(11, 32'h00000004, "x11 via selected_register");
        
        // Test 8: Mostrar x20 (debería ser 10 = 0xA)
        SW = 5'd20;
        #50;
        print_displays("Register x20 (should be 0x00000A)");
        check_display(20, 24'h00000A, "x20 register");
        check_selected_register(20, 32'h0000000A, "x20 via selected_register");
        
        // Test 9: Mostrar x22 (debería ser 5)
        SW = 5'd22;
        #50;
        print_displays("Register x22 (should be 0x000005)");
        check_display(22, 24'h000005, "x22 register");
        check_selected_register(22, 32'h00000005, "x22 via selected_register");
        
        // Test 10: Barrido rápido de todos los registros
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════╗");
        $display("║              Scanning All 32 Registers                    ║");
        $display("║          Verifying both Displays and selected_register    ║");
        $display("╚═══════════════════════════════════════════════════════════╝");
        #500
        for (int i = 0; i < 32; i = i + 1) begin
            SW = i[4:0];
            #50;
            $display("x%-2d | Display: 0x%06h | selected_register: 0x%08h", 
                     i, get_display_value(), debug_selected_register);
            
            // Verificar que los 24 bits inferiores de selected_register coincidan con los displays
            if (get_display_value() !== debug_selected_register[23:0]) begin
                $error("MISMATCH: Display shows 0x%06h but selected_register[23:0] = 0x%06h for x%0d",
                       get_display_value(), debug_selected_register[23:0], i);
                error_count = error_count + 1;
            end
        end
        
        // Resumen final
        $display("\n");
        $display("╔═══════════════════════════════════════════════════════════╗");
        $display("║                        Summary                            ║");
        $display("╚═══════════════════════════════════════════════════════════╝");
        $display("Total cycles executed: %0d", cycle_count);
        $display("Total display tests: 9");
        $display("Total selected_register tests: 9");
        $display("Total register scan tests: 32");
        $display("Total consistency tests (Display vs selected_register): 32");
        $display("Total errors: %0d", error_count);
        
        if (error_count == 0) begin
            $display("\n✅ All tests passed successfully!");
            $display("   ✓ Display values are correct");
            $display("   ✓ selected_register values are correct");
            $display("   ✓ Display and selected_register are consistent");
        end else begin
            $display("\n❌ Found %0d test errors", error_count);
        end
        
        #100;
        $finish;
    end
    
    // Timeout de seguridad
    initial begin
        #50000;  // 50 microsegundos
        $error("⏱️  TIMEOUT: Testbench took too long");
        $finish;
    end

endmodule
