module DataMemory(
    input logic clk,
    input logic [31:0] Address,
    input logic [31:0] DataWr,
    input logic DMWr,
    input logic [2:0] DMCtrl,
    output logic [31:0] DataRd
);

    localparam  LB   = 3'b000,
                LH   = 3'b001,
                LW   = 3'b010,
                LB_U = 3'b100,
                LH_U = 3'b101,
                SB   = 3'b000,
                SH   = 3'b001,
                SW   = 3'b010;

    logic [7:0] dm [0:200]; // 8 KiB

    // Read
    always @* begin
        case (DMCtrl)
            LB:      DataRd = {{24{dm[Address][7]}}, dm[Address]};
            LB_U:    DataRd = {24'b0, dm[Address]};
            LH:      DataRd = {{16{dm[Address+1][7]}}, dm[Address+1], dm[Address]};
            LH_U:    DataRd = {16'b0, dm[Address+1], dm[Address]};
            LW:      DataRd = {dm[Address+3], dm[Address+2], dm[Address+1], dm[Address]};
            default: DataRd = 32'b0;
        endcase
    end

    // Synchronous WRITE
    always_ff @(posedge clk) begin
        if (DMWr) begin
            case (DMCtrl)
                SB: dm[Address] <= DataWr[7:0];
                SH: begin
                    dm[Address]   <= DataWr[7:0];
                    dm[Address+1] <= DataWr[15:8];
                end
                SW: begin
                    dm[Address]   <= DataWr[7:0];
                    dm[Address+1] <= DataWr[15:8];
                    dm[Address+2] <= DataWr[23:16];
                    dm[Address+3] <= DataWr[31:24];
                end
            endcase
        end
    end

endmodule