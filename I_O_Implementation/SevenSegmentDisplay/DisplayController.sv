/**
 * Display Controller
 * Controla 6 displays de 7 segmentos para mostrar valores de 24 bits
 * 
 * @input  data_to_display => Dato de 24 bits a mostrar en hexadecimal
 * @output hex0-hex5       => Salidas para 6 displays de 7 segmentos
 * 
 * Distribución:
 * - HEX0: bits [3:0]   (nibble menos significativo)
 * - HEX1: bits [7:4]
 * - HEX2: bits [11:8]
 * - HEX3: bits [15:12]
 * - HEX4: bits [19:16]
 * - HEX5: bits [23:20] (nibble más significativo)
 * 
 * Ejemplo: data_to_display = 0xABCDEF
 *   HEX5 HEX4 HEX3 HEX2 HEX1 HEX0
 *    A    B    C    D    E    F
 */
module DisplayController(
    input logic [23:0] data_to_display,  // Dato a mostrar (24 bits)
    output logic [6:0] hex0,             // Display 0 (LSB)
    output logic [6:0] hex1,             // Display 1
    output logic [6:0] hex2,             // Display 2
    output logic [6:0] hex3,             // Display 3
    output logic [6:0] hex4,             // Display 4
    output logic [6:0] hex5              // Display 5 (MSB)
);

    // Extraer nibbles directamente (data_to_display ya debe estar limpio)
    wire [3:0] nibble0_clean = data_to_display[3:0];
    wire [3:0] nibble1_clean = data_to_display[7:4];
    wire [3:0] nibble2_clean = data_to_display[11:8];
    wire [3:0] nibble3_clean = data_to_display[15:12];
    wire [3:0] nibble4_clean = data_to_display[19:16];
    wire [3:0] nibble5_clean = data_to_display[23:20];

    // Instanciar 6 decodificadores de 7 segmentos
    // Cada uno maneja un nibble (4 bits) limpio
    logic [6:0] hex0_raw, hex1_raw, hex2_raw;
    logic [6:0] hex3_raw, hex4_raw, hex5_raw;
    
    SevenSegmentDisplay disp0 (
        .hex_value(nibble0_clean),
        .segments(hex0_raw)
    );

    SevenSegmentDisplay disp1 (
        .hex_value(nibble1_clean),
        .segments(hex1_raw)
    );

    SevenSegmentDisplay disp2 (
        .hex_value(nibble2_clean),
        .segments(hex2_raw)
    );

    SevenSegmentDisplay disp3 (
        .hex_value(nibble3_clean),
        .segments(hex3_raw)
    );

    SevenSegmentDisplay disp4 (
        .hex_value(nibble4_clean),
        .segments(hex4_raw)
    );

    SevenSegmentDisplay disp5 (
        .hex_value(nibble5_clean),
        .segments(hex5_raw)
    );

    // Limpiar outputs finales: forzar valores 'x' a '1' (apagado en activo bajo)
    // Asignaciones directas para cada bit de cada display
    assign hex0[0] = (hex0_raw[0] === 1'bx) ? 1'b1 : hex0_raw[0];
    assign hex0[1] = (hex0_raw[1] === 1'bx) ? 1'b1 : hex0_raw[1];
    assign hex0[2] = (hex0_raw[2] === 1'bx) ? 1'b1 : hex0_raw[2];
    assign hex0[3] = (hex0_raw[3] === 1'bx) ? 1'b1 : hex0_raw[3];
    assign hex0[4] = (hex0_raw[4] === 1'bx) ? 1'b1 : hex0_raw[4];
    assign hex0[5] = (hex0_raw[5] === 1'bx) ? 1'b1 : hex0_raw[5];
    assign hex0[6] = (hex0_raw[6] === 1'bx) ? 1'b1 : hex0_raw[6];
    
    assign hex1[0] = (hex1_raw[0] === 1'bx) ? 1'b1 : hex1_raw[0];
    assign hex1[1] = (hex1_raw[1] === 1'bx) ? 1'b1 : hex1_raw[1];
    assign hex1[2] = (hex1_raw[2] === 1'bx) ? 1'b1 : hex1_raw[2];
    assign hex1[3] = (hex1_raw[3] === 1'bx) ? 1'b1 : hex1_raw[3];
    assign hex1[4] = (hex1_raw[4] === 1'bx) ? 1'b1 : hex1_raw[4];
    assign hex1[5] = (hex1_raw[5] === 1'bx) ? 1'b1 : hex1_raw[5];
    assign hex1[6] = (hex1_raw[6] === 1'bx) ? 1'b1 : hex1_raw[6];
    
    assign hex2[0] = (hex2_raw[0] === 1'bx) ? 1'b1 : hex2_raw[0];
    assign hex2[1] = (hex2_raw[1] === 1'bx) ? 1'b1 : hex2_raw[1];
    assign hex2[2] = (hex2_raw[2] === 1'bx) ? 1'b1 : hex2_raw[2];
    assign hex2[3] = (hex2_raw[3] === 1'bx) ? 1'b1 : hex2_raw[3];
    assign hex2[4] = (hex2_raw[4] === 1'bx) ? 1'b1 : hex2_raw[4];
    assign hex2[5] = (hex2_raw[5] === 1'bx) ? 1'b1 : hex2_raw[5];
    assign hex2[6] = (hex2_raw[6] === 1'bx) ? 1'b1 : hex2_raw[6];
    
    assign hex3[0] = (hex3_raw[0] === 1'bx) ? 1'b1 : hex3_raw[0];
    assign hex3[1] = (hex3_raw[1] === 1'bx) ? 1'b1 : hex3_raw[1];
    assign hex3[2] = (hex3_raw[2] === 1'bx) ? 1'b1 : hex3_raw[2];
    assign hex3[3] = (hex3_raw[3] === 1'bx) ? 1'b1 : hex3_raw[3];
    assign hex3[4] = (hex3_raw[4] === 1'bx) ? 1'b1 : hex3_raw[4];
    assign hex3[5] = (hex3_raw[5] === 1'bx) ? 1'b1 : hex3_raw[5];
    assign hex3[6] = (hex3_raw[6] === 1'bx) ? 1'b1 : hex3_raw[6];
    
    assign hex4[0] = (hex4_raw[0] === 1'bx) ? 1'b1 : hex4_raw[0];
    assign hex4[1] = (hex4_raw[1] === 1'bx) ? 1'b1 : hex4_raw[1];
    assign hex4[2] = (hex4_raw[2] === 1'bx) ? 1'b1 : hex4_raw[2];
    assign hex4[3] = (hex4_raw[3] === 1'bx) ? 1'b1 : hex4_raw[3];
    assign hex4[4] = (hex4_raw[4] === 1'bx) ? 1'b1 : hex4_raw[4];
    assign hex4[5] = (hex4_raw[5] === 1'bx) ? 1'b1 : hex4_raw[5];
    assign hex4[6] = (hex4_raw[6] === 1'bx) ? 1'b1 : hex4_raw[6];
    
    assign hex5[0] = (hex5_raw[0] === 1'bx) ? 1'b1 : hex5_raw[0];
    assign hex5[1] = (hex5_raw[1] === 1'bx) ? 1'b1 : hex5_raw[1];
    assign hex5[2] = (hex5_raw[2] === 1'bx) ? 1'b1 : hex5_raw[2];
    assign hex5[3] = (hex5_raw[3] === 1'bx) ? 1'b1 : hex5_raw[3];
    assign hex5[4] = (hex5_raw[4] === 1'bx) ? 1'b1 : hex5_raw[4];
    assign hex5[5] = (hex5_raw[5] === 1'bx) ? 1'b1 : hex5_raw[5];
    assign hex5[6] = (hex5_raw[6] === 1'bx) ? 1'b1 : hex5_raw[6];

endmodule
