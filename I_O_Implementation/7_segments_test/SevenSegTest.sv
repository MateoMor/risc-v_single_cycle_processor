/**
 * Seven Segment Display Test
 * Muestra el valor de los switches en hexadecimal en los displays
 * Usa los módulos SevenSegmentDisplay y DisplayController
 * 
 * SW[4:0] = 5 bits de entrada (0-31)
 * Muestra en HEX1-HEX0 el valor en hexadecimal (0x00 - 0x1F)
 * 
 * @input  SW[4:0] => 5 switches de entrada
 * @output HEX0-HEX5 => Displays de 7 segmentos (activo bajo)
 */
module SevenSegTest(
    input  logic [4:0] SW,       // 5 switches de entrada
    output logic [6:0] HEX0,     // Display menos significativo
    output logic [6:0] HEX1,     // Display más significativo
    output logic [6:0] HEX2,     // Apagado
    output logic [6:0] HEX3,     // Apagado
    output logic [6:0] HEX4,     // Apagado
    output logic [6:0] HEX5      // Apagado
);

    // Convertir 5 bits a 24 bits para DisplayController
    // SW[4:0] = 0-31 (0x00 - 0x1F)
    logic [23:0] display_data;
    
    assign display_data = {19'b0, SW[4:0]};  // Extender a 24 bits con ceros
    
    // Instanciar DisplayController para decodificar los 6 displays
    DisplayController display_ctrl (
        .data_to_display(display_data),
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3),
        .hex4(HEX4),
        .hex5(HEX5)
    );

endmodule
