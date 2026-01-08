/**
 * Testbench para SevenSegTest
 * Prueba todas las combinaciones de switches y verifica los displays
 */
module SevenSegTest_tb;

    // Señales del testbench
    logic [4:0] SW;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    // Instanciar el módulo bajo prueba
    SevenSegTest dut (
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
    
    // Función para decodificar 7 segmentos a hexadecimal
    function automatic logic [3:0] decode_7seg;
        input logic [6:0] seg;
        case (seg)
            7'b1000000: decode_7seg = 4'h0;
            7'b1111001: decode_7seg = 4'h1;
            7'b0100100: decode_7seg = 4'h2;
            7'b0110000: decode_7seg = 4'h3;
            7'b0011001: decode_7seg = 4'h4;
            7'b0010010: decode_7seg = 4'h5;
            7'b0000010: decode_7seg = 4'h6;
            7'b1111000: decode_7seg = 4'h7;
            7'b0000000: decode_7seg = 4'h8;
            7'b0010000: decode_7seg = 4'h9;
            7'b0001000: decode_7seg = 4'hA;
            7'b0000011: decode_7seg = 4'hB;
            7'b1000110: decode_7seg = 4'hC;
            7'b0100001: decode_7seg = 4'hD;
            7'b0000110: decode_7seg = 4'hE;
            7'b0001110: decode_7seg = 4'hF;
            default:    decode_7seg = 4'hX;
        endcase
    endfunction
    
    // Task para imprimir el estado actual
    task print_state;
        logic [3:0] hex0_val, hex1_val;
        logic [7:0] display_value;
        
        hex0_val = decode_7seg(HEX0);
        hex1_val = decode_7seg(HEX1);
        display_value = {hex1_val, hex0_val};
        
        $display("SW=%5b (%2d) → HEX1=%h HEX0=%h → Display: %02h (%2d)", 
                 SW, SW, hex1_val, hex0_val, display_value, display_value);
    endtask
    
    // Task para verificar el valor
    task check_value;
        input logic [4:0] expected;
        logic [3:0] hex0_val, hex1_val;
        logic [7:0] display_value;
        
        hex0_val = decode_7seg(HEX0);
        hex1_val = decode_7seg(HEX1);
        display_value = {hex1_val, hex0_val};
        
        if (display_value == expected) begin
            $display("  ✅ PASS: Display correcto %02h", display_value);
        end else begin
            $display("  ❌ FAIL: Esperado %02h, obtenido %02h", expected, display_value);
        end
    endtask
    
    // Proceso de prueba
    initial begin
        $display("========================================");
        $display("  SevenSegTest Testbench");
        $display("========================================");
        $display("");
        
        // Prueba 1: Valores específicos
        $display("📋 Prueba 1: Valores específicos");
        $display("----------------------------------------");
        
        SW = 5'b00000; #10; print_state(); check_value(5'd0);
        SW = 5'b00001; #10; print_state(); check_value(5'd1);
        SW = 5'b00101; #10; print_state(); check_value(5'd5);
        SW = 5'b01010; #10; print_state(); check_value(5'd10);
        SW = 5'b01111; #10; print_state(); check_value(5'd15);
        SW = 5'b10000; #10; print_state(); check_value(5'd16);
        SW = 5'b10101; #10; print_state(); check_value(5'd21);
        SW = 5'b11111; #10; print_state(); check_value(5'd31);
        
        $display("");
        
        // Prueba 2: Todos los valores (0-31)
        $display("📋 Prueba 2: Escaneo completo (0-31)");
        $display("----------------------------------------");
        
        for (int i = 0; i < 32; i++) begin
            SW = i[4:0];
            #10;
            print_state();
            check_value(i[4:0]);
        end
        
        $display("");
        
        // Prueba 3: Verificar displays apagados
        $display("📋 Prueba 3: Verificar HEX2-5 apagados");
        $display("----------------------------------------");
        
        SW = 5'b10101; #10;
        
        if (HEX2 == 7'b1111111) begin
            $display("  ✅ HEX2 apagado correctamente");
        end else begin
            $display("  ❌ HEX2 debería estar apagado");
        end
        
        if (HEX3 == 7'b1111111) begin
            $display("  ✅ HEX3 apagado correctamente");
        end else begin
            $display("  ❌ HEX3 debería estar apagado");
        end
        
        if (HEX4 == 7'b1111111) begin
            $display("  ✅ HEX4 apagado correctamente");
        end else begin
            $display("  ❌ HEX4 debería estar apagado");
        end
        
        if (HEX5 == 7'b1111111) begin
            $display("  ✅ HEX5 apagado correctamente");
        end else begin
            $display("  ❌ HEX5 debería estar apagado");
        end
        
        $display("");
        $display("========================================");
        $display("  Pruebas completadas ✨");
        $display("========================================");
        
        $finish;
    end

endmodule
