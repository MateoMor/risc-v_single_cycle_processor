module RegistersUnit(
    input logic clk,
    input logic [4:0] rs1,
    input logic [4:0] rs2,
    input logic [4:0] rd,

    input logic [31:0] DataWR,
    input logic RUWr, // read 0 / write 1

    output logic [31:0] ru_rs1,
    output logic [31:0] ru_rs2,
    
    // Puerto adicional para visualización en displays
    input logic [4:0] reg_select,
    output logic [31:0] reg_out
);
    // register matrix - inicializar todos a 0 para evitar valores 'x'
    logic [31:0] ru [31:0]; // 32 registers of 32 bits each

    // Inicializar todos los registros a 0
    initial begin
        for (int i = 0; i < 32; i = i + 1) begin
            ru[i] = 32'h0;
        end
    end

    // lecturas con forwarding y x0 forzado a 0
    assign ru_rs1 = (rs1 == 0) ? 32'd0 :
                    ((RUWr && rd != 0 && rd == rs1) ? DataWR : ru[rs1]); // forwarding: if you try to read and write the same register, then assign DataWR to ru_rs1 temporarily
    assign ru_rs2 = (rs2 == 0) ? 32'd0 :
                    ((RUWr && rd != 0 && rd == rs2) ? DataWR : ru[rs2]);
    
    // Salida del registro seleccionado para displays (x0 siempre es 0)
    assign reg_out = (reg_select == 0) ? 32'd0 : ru[reg_select];

    always @(posedge clk) begin
        if (RUWr && rd != 0) begin
            ru[rd] <= DataWR;
        end 
    end
endmodule