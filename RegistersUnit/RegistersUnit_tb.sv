`timescale 1ns/1ps

module RegistersUnit_tb;

	// Signals
	logic clk;
	logic [4:0] rs1, rs2, rd;
	logic [31:0] DataWR;
	logic RUWr;
	logic [31:0] ru_rs1, ru_rs2;
	
	// Nuevas señales para reg_out
	logic [4:0] reg_select;
	logic [31:0] reg_out;

	// Device under test
	RegistersUnit dut (
		.clk(clk),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.DataWR(DataWR),
		.RUWr(RUWr),
		.ru_rs1(ru_rs1),
		.ru_rs2(ru_rs2),
		.reg_select(reg_select),
		.reg_out(reg_out)
	);

	// Clock
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	// TEST SEQUENCE
	initial begin
		$dumpfile("RegistersUnit_tb.vcd");
		$dumpvars(0, RegistersUnit_tb);

		$display("========================================");
		$display("  RegistersUnit Testbench");
		$display("  Testing reg_out functionality");
		$display("========================================");
		$display("");

		// default
		rs1 = '0; rs2 = '0; rd = '0; DataWR = '0; RUWr = 1'b0; reg_select = '0;

		// ===== PRUEBAS ORIGINALES =====
		$display("📋 Prueba 1: x0 debe leer siempre 0");
		$display("----------------------------------------");
		
		// 1. x0 must read zero (force rs1 before sample)
		rs1 = 5'd0; #1;
		if (ru_rs1 !== 32'd0) begin
			$display("  ❌ FAIL: x0 should read 0 via rs1, got %h", ru_rs1);
		end else begin
			$display("  ✅ PASS: x0 lee 0 via rs1");
		end
		
		// Verificar x0 via reg_out
		reg_select = 5'd0; #1;
		if (reg_out !== 32'd0) begin
			$display("  ❌ FAIL: x0 should read 0 via reg_out, got %h", reg_out);
		end else begin
			$display("  ✅ PASS: x0 lee 0 via reg_out");
		end
		
		$display("");

		// 2. write x5 = 4 (synchronous) and read back
		$display("📋 Prueba 2: Escribir x5=4 y leer");
		$display("----------------------------------------");
		
		write_reg(5'd5, 32'h4);
		rs1 = 5'd5; #1;
		if (ru_rs1 !== 32'h4) begin
			$display("  ❌ FAIL: Read after write mismatch for x5 via rs1: %h", ru_rs1);
		end else begin
			$display("  ✅ PASS: x5=4 via rs1");
		end
		
		// Verificar via reg_out
		reg_select = 5'd5; #1;
		if (reg_out !== 32'h4) begin
			$display("  ❌ FAIL: Read after write mismatch for x5 via reg_out: %h", reg_out);
		end else begin
			$display("  ✅ PASS: x5=4 via reg_out");
		end
		
		$display("");

		// 3. forwarding: prepare read index, then assert write signals briefly
		$display("📋 Prueba 3: Forwarding x7=13");
		$display("----------------------------------------");
		
		rs2 = 5'd7; // prepare read address
		trigger_forwarding(5'd7, 32'd13); // should make ru_rs2 == 13 while RUWr asserted
		if (ru_rs2 !== 32'd13) begin
			$display("  ❌ FAIL: Forwarding failed for x7 via rs2: %h", ru_rs2);
		end else begin
			$display("  ✅ PASS: Forwarding x7=13 via rs2");
		end

		// commit the value for subsequent checks
		write_reg(5'd7, 32'd13);
		
		// Verificar via reg_out después de commit
		reg_select = 5'd7; #1;
		if (reg_out !== 32'd13) begin
			$display("  ❌ FAIL: x7 via reg_out después de commit: %h", reg_out);
		end else begin
			$display("  ✅ PASS: x7=13 via reg_out");
		end
		
		$display("");

		// 4. dual read
		$display("📋 Prueba 4: Lectura dual rs1=x5, rs2=x7");
		$display("----------------------------------------");
		
		rs1 = 5'd5; rs2 = 5'd7; #1;
		if ((ru_rs1 !== 32'h4) || (ru_rs2 !== 32'd13)) begin
			$display("  ❌ FAIL: Dual read mismatch: rs1=%h rs2=%h", ru_rs1, ru_rs2);
		end else begin
			$display("  ✅ PASS: rs1[x5]=4, rs2[x7]=13");
		end
		
		$display("");

		// ===== NUEVAS PRUEBAS PARA REG_OUT =====
		$display("📋 Prueba 5: Escribir múltiples registros y verificar con reg_out");
		$display("----------------------------------------");
		
		write_reg(5'd8, 32'h00000004);   // x8 = 4
		write_reg(5'd9, 32'h0000000C);   // x9 = 12
		write_reg(5'd10, 32'h00000010);  // x10 = 16
		write_reg(5'd13, 32'h0000000A);  // x13 = 10
		write_reg(5'd20, 32'h0000000A);  // x20 = 10
		write_reg(5'd22, 32'h00000005);  // x22 = 5
		
		check_reg_out(5'd8, 32'h00000004);
		check_reg_out(5'd9, 32'h0000000C);
		check_reg_out(5'd10, 32'h00000010);
		check_reg_out(5'd13, 32'h0000000A);
		check_reg_out(5'd20, 32'h0000000A);
		check_reg_out(5'd22, 32'h00000005);
		
		$display("");
		
		$display("📋 Prueba 6: Escaneo de todos los registros no vacíos");
		$display("----------------------------------------");
		
		for (int i = 0; i < 32; i++) begin
			reg_select = i[4:0];
			#1;
			if (reg_out != 32'h00000000) begin
				$display("  x%2d = 0x%08h (%10d)", i, reg_out, reg_out);
			end
		end
		
		$display("");
		$display("========================================");
		$display("  Todas las pruebas completadas ✨");
		$display("========================================");

		$finish;
	end

	// synchronous write: set signals during low phase and keep until after posedge
	task automatic write_reg(input logic [4:0] dest, input logic [31:0] value);
		@(negedge clk);
		RUWr = 1'b1; rd = dest; DataWR = value;
		@(posedge clk);
		#1; // allow DUT to update outputs
		RUWr = 1'b0; rd = '0; DataWR = '0;
	endtask

	// forwarding: assert RUWr/rd/DataWR briefly (no commit) and let combinational path settle
	task automatic trigger_forwarding(input logic [4:0] dest, input logic [31:0] value);
		@(negedge clk);
		RUWr = 1'b1; rd = dest; DataWR = value;
		#1; // sample forwarding
		RUWr = 1'b0; rd = '0; DataWR = '0;
	endtask
	
	// Tarea para verificar reg_out
	task automatic check_reg_out(input logic [4:0] register, input logic [31:0] expected_value);
		reg_select = register;
		#1;  // Esperar combinacional
		if (reg_out == expected_value) begin
			$display("  ✅ PASS: reg_out[x%2d] = 0x%08h", register, reg_out);
		end else begin
			$display("  ❌ FAIL: reg_out[x%2d] = 0x%08h (esperado: 0x%08h)", 
					 register, reg_out, expected_value);
		end
	endtask

endmodule
