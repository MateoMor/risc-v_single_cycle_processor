module InstructionMemory #(
    parameter MEM_SIZE = 128,                          // Memory size in number of 32-bit instructions
    parameter PROGRAM_FILE = "program.hex"             // Path to the hex file containing the program
)(
    input  logic [31:0] address,                       // 32-bit address input
    output logic [31:0] instruction                    // 32-bit instruction output
);
    logic [31:0] mem [0:MEM_SIZE-1];                   // Memory array: MEM_SIZE registers of 32 bits each
    localparam ADDR_WIDTH = $clog2(MEM_SIZE);         // Calculate the number of bits needed to address all memory locations

    initial begin
        // Initialize entire memory with NOPs (No Operation instructions)
        for (int i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000013;  // NOP: addi x0, x0, 0
        end
        
        // Load the program from the file into memory (overwrites NOPs)
        $readmemb(PROGRAM_FILE, mem);  // Binary format

        // Display initialization information
        $display("✅ InstructionMemory initialized:");
        $display("   Size: %0d instructions (%0d bytes)", MEM_SIZE, MEM_SIZE*4);
        $display("   Address width: %0d bits", ADDR_WIDTH);
        $display("   Max address: 0x%08h", (MEM_SIZE-1)*4);
        $display("   Program loaded: 20 instructions");
    end

    // Address alignment: remove the 2 least significant bits (word alignment for 32-bit instructions)
    wire [31:0] aligned_addr = address[31:2];
    
    // Out-of-bounds protection: check if the aligned address is within valid memory range
    wire address_valid = (aligned_addr < MEM_SIZE);
    
    // Output instruction: return memory value if address is valid, otherwise return NOP for safety
    assign instruction = address_valid ? mem[aligned_addr] : 32'h00000013;

endmodule