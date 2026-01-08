/**
 * RISC-V Single Cycle Processor - FPGA Wrapper
 * Wrapper para conectar el procesador a periféricos de FPGA
 * 
 * Características:
 * - Memory-mapped I/O para displays de 7 segmentos
 * - Dirección 0xFFFFFFFC reservada para el display
 * - Muestra valores de 24 bits en formato hexadecimal (6 displays)
 * - Visualización de registros mediante switches
 * 
 * @input  clk    => Señal de reloj de la FPGA
 * @input  reset  => Señal de reset (activo alto)
 * @input  SW[4:0]=> Selector de registro (0-31)
 * @output HEX0-5 => Salidas para 6 displays de 7 segmentos
 * 
 * Los switches SW[4:0] seleccionan qué registro mostrar:
 *   00000 = x0, 00001 = x1, ..., 11111 = x31
 */
module RiscV_SingleCycle_FPGA #(
    parameter IMEM_SIZE = 128,
    parameter PROGRAM_FILE = "../test_programs/program.hex"
)(
    input logic clk,
    input logic reset,
    input logic [4:0] SW,  // Switches para seleccionar registro (0-31)
    
    // Displays de 7 segmentos (activo bajo) - 6 displays
    output logic [6:0] HEX0,  // Nibble [3:0]
    output logic [6:0] HEX1,  // Nibble [7:4]
    output logic [6:0] HEX2,  // Nibble [11:8]
    output logic [6:0] HEX3,  // Nibble [15:12]
    output logic [6:0] HEX4,  // Nibble [19:16]
    output logic [6:0] HEX5,  // Nibble [23:20]
    
    // Debug ports (para testbench)
    output logic [31:0] debug_selected_register
);

    // ========== Dirección Memory-Mapped del Display ==========
    localparam DISPLAY_ADDR = 32'hFFFFFFFC;
    
    // ========== Señales Internas del Procesador ==========
    
    // Program Counter
    logic [31:0] PC;
    logic [31:0] NextPC;
    logic [31:0] PC_plus_4;
    
    // Instruction Memory
    logic [31:0] Instruction;
    
    // Instruction fields
    logic [6:0] OpCode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] Funct3;
    logic [6:0] Funct7;
    logic [24:0] InmediateBits;
    
    // Control Unit signals
    logic       RUWr;
    logic       ALUASrc;
    logic       ALUBSrc;
    logic [3:0] ALUOp;
    logic [2:0] ImmSrc;
    logic [4:0] BrOp;
    logic       DMWr;
    logic [2:0] DMCtrl;
    logic [1:0] RUDataWrSrc;
    
    // Register Unit
    logic [31:0] ru_rs1;
    logic [31:0] ru_rs2;
    logic [31:0] RU_DataWr;
    
    // Immediate Generator
    logic [31:0] ImmExt;
    
    // ALU inputs and output
    logic [31:0] ALU_A;
    logic [31:0] ALU_B;
    logic [31:0] ALURes;
    
    // Branch Unit
    logic NextPCsrc;
    
    // Data Memory
    logic [31:0] DataRd;
    
    // Display Register
    logic [31:0] display_register;
    
    // Register selection for display
    logic [31:0] selected_register;
    
    // Memory control signals
    logic is_display_write;
    logic is_display_read;
    logic DMWr_internal;  // Escritura a memoria real (no display)
    
    
    // ========== Decodificación de Instrucciones ==========
    assign OpCode        = Instruction[6:0];
    assign rd            = Instruction[11:7];
    assign Funct3        = Instruction[14:12];
    assign rs1           = Instruction[19:15];
    assign rs2           = Instruction[24:20];
    assign Funct7        = Instruction[31:25];
    assign InmediateBits = Instruction[31:7];
    
    // PC + 4
    assign PC_plus_4 = PC + 32'd4;
    
    
    // ========== Memory-Mapped I/O Logic ==========
    
    // Detectar acceso al display
    assign is_display_write = (ALURes == DISPLAY_ADDR) && DMWr;
    assign is_display_read  = (ALURes == DISPLAY_ADDR) && (RUDataWrSrc == 2'b01);
    
    // Redirigir escritura: si es al display, no escribir en DataMemory
    assign DMWr_internal = DMWr && !is_display_write;
    
    // Registro del Display (actualizado con SW a 0xFFFFFFFC)
    always_ff @(posedge clk) begin
        if (reset) begin
            display_register <= 32'h00000000;
        end else if (is_display_write) begin
            display_register <= ru_rs2;
        end
    end
    
    
    // ========== Instanciación de Módulos ==========
    
    // Program Counter
    ProgramCounter pc_inst (
        .clk(clk),
        .reset(reset),
        .next_pc(NextPC),
        .pc(PC)
    );
    
    // Instruction Memory
    InstructionMemory #(
        .MEM_SIZE(IMEM_SIZE),
        .PROGRAM_FILE(PROGRAM_FILE)
    ) imem_inst (
        .address(PC),
        .instruction(Instruction)
    );
    
    // Control Unit
    ControlUnit control_inst (
        .OpCode(OpCode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .RUWr(RUWr),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .ALUOp(ALUOp),
        .ImmSrc(ImmSrc),
        .BrOp(BrOp),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .RUDataWrSrc(RUDataWrSrc)
    );
    
    // Register Unit
    RegistersUnit reg_unit_inst (
        .clk(clk),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .DataWR(RU_DataWr),
        .RUWr(RUWr),
        .ru_rs1(ru_rs1),
        .ru_rs2(ru_rs2),
        .reg_select(SW),              // Selector de registro desde switches
        .reg_out(selected_register)   // Salida del registro seleccionado
    );
    
    // Immediate Generator
    ImmGen immgen_inst (
        .InmediateBits(InmediateBits),
        .ImmSrc(ImmSrc),
        .ImmExt(ImmExt)
    );
    
    // ALU Input A Multiplexer
    ALUA mux_alua_inst (
        .ALUAsrc(ALUASrc),
        .PC(PC),
        .ru_rs1(ru_rs1),
        .A(ALU_A)
    );
    
    // ALU Input B Multiplexer
    ALUB mux_alub_inst (
        .ALUBsrc(ALUBSrc),
        .ru_rs2(ru_rs2),
        .ImmExt(ImmExt),
        .B(ALU_B)
    );
    
    // ALU
    ALU alu_inst (
        .A(ALU_A),
        .B(ALU_B),
        .ALUOp(ALUOp),
        .ALURes(ALURes)
    );
    
    // Branch Unit
    BranchUnit branch_inst (
        .ru_rs1(ru_rs1),
        .ru_rs2(ru_rs2),
        .BrOp(BrOp),
        .NextPCsrc(NextPCsrc)
    );
    
    // Data Memory (con control de escritura modificado)
    DataMemory dmem_inst (
        .clk(clk), 
        .Address(ALURes),
        .DataWr(ru_rs2),
        .DMWr(DMWr_internal),  // Solo escribe si NO es al display
        .DMCtrl(DMCtrl),
        .DataRd(DataRd)
    );
    
    // Register Write Data Multiplexer (con lectura del display)
    RUDataWr mux_ru_data_inst (
        .RUDataWrSrc(RUDataWrSrc),
        .PC_with_offset(PC_plus_4),
        .DataRd(is_display_read ? display_register : DataRd),  // Leer display o memoria
        .ALURes(ALURes),
        .DataWr(RU_DataWr)
    );
    
    // Next PC Multiplexer
    NextPC mux_nextpc_inst (
        .NextPCsrc(NextPCsrc),
        .PC_with_offset(PC_plus_4),
        .ALURes(ALURes),
        .NextPC(NextPC)
    );
    
    // ========== Display Controller ==========
    // Muestra el registro seleccionado por los switches SW[4:0]
    // DisplayController ahora solo recibe 24 bits para 6 displays
    
    // Limpiar valores 'x' en los 24 bits inferiores antes de mostrar
    logic [23:0] clean_register_display;
    genvar i;
    generate
        for (i = 0; i < 24; i = i + 1) begin : clean_display_bits
            assign clean_register_display[i] = (selected_register[i] === 1'bx) ? 1'b0 : selected_register[i];
        end
    endgenerate
    
    DisplayController display_ctrl (
        .data_to_display(clean_register_display),  // Pasar valor limpio sin 'x'
        .hex0(HEX0),
        .hex1(HEX1),
        .hex2(HEX2),
        .hex3(HEX3),
        .hex4(HEX4),
        .hex5(HEX5)
    );
    
    // ========== Debug Ports ==========
    // Exponer selected_register para verificación en testbench
    assign debug_selected_register = selected_register;

endmodule
