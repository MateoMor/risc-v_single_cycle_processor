/**
 * Seven Segment Display Decoder
 * Convierte un valor hexadecimal (0-F) a segmentos de display
 * 
 * @input  hex_value => Valor hexadecimal de 4 bits (0x0 - 0xF)
 * @output segments  => 7 segmentos [6:0] = {g,f,e,d,c,b,a}
 * 
 * Configuración para display común ánodo (activo bajo):
 *     a
 *    ---
 * f |   | b
 *    -g-
 * e |   | c
 *    ---
 *     d
 * 
 * segments[0] = a
 * segments[1] = b
 * segments[2] = c
 * segments[3] = d
 * segments[4] = e
 * segments[5] = f
 * segments[6] = g
 */
module SevenSegmentDisplay(
    input logic [3:0] hex_value,      // Valor hexadecimal (0-F)
    output logic [6:0] segments       // Segmentos a-g (activo bajo)
);

    // Decodificación para cada dígito hexadecimal
    always_comb begin
        case (hex_value)
            // 4'h0: segments = 7'b1000000; // 0
            4'h0: segments = 7'b1111110; // 0
            4'h1: segments = 7'b1111001; // 1
            4'h2: segments = 7'b0100100; // 2
            4'h3: segments = 7'b0110000; // 3
            4'h4: segments = 7'b0011001; // 4
            4'h5: segments = 7'b0010010; // 5
            4'h6: segments = 7'b0000010; // 6
            4'h7: segments = 7'b1111000; // 7
            4'h8: segments = 7'b0000000; // 8
            4'h9: segments = 7'b0010000; // 9
            4'hA: segments = 7'b0001000; // A
            4'hB: segments = 7'b0000011; // b
            4'hC: segments = 7'b1000110; // C
            4'hD: segments = 7'b0100001; // d
            4'hE: segments = 7'b0000110; // E
            4'hF: segments = 7'b0001110; // F
            default: segments = 7'b1111111; // Apagado
        endcase
    end

endmodule
