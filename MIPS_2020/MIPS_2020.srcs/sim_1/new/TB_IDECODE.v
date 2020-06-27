`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2020 10:25:30
// Design Name: 
// Module Name: TB_IDECODE
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



`define LEN 32

module TB_IDECODE(

    );
	
	reg clk;
	reg reset;
	reg i_flush;
	reg [`LEN-1:0] i_pcBranch = `LEN'b11111111000000001111111100000000;//dirección de salto
	reg [`LEN-1:0] i_instruction;
	reg [`LEN-1:0] i_writeData;
	reg i_flagRegWrite;
	reg [$clog2(`LEN)-1:0] i_writeRegister;
	
	IDECODE #(
		.len(`LEN)
		)
		IDECODE (
			.clk(clk),
			.i_pcBranch(i_pcBranch),
			.i_instruction(i_instruction),
			.i_flagRegWrite(i_flagRegWrite),
			.i_writeData(i_writeData),
			.i_writeRegister(i_writeRegister),
			.i_flush (i_flush),
			.reset(reset)
		);

	initial
	begin
		clk = 0;
		reset = 0;
        i_flush = 0;
		i_flagRegWrite = 1;
		i_writeRegister = 0;
		i_writeData = `LEN'h4;
		// escribo en el registro [0] el valor 4
		
		#30

		i_writeRegister = 1;
		i_writeData = `LEN'h7;
		// escribo en el registro 1 el valor 7

		#30

		i_flagRegWrite = 0;
		//i_instruction = `LEN'b00000000001000100010000000100001; //opcode = 0, rs = 1, rt = 2, rd = 4, shamp = 0, function = ADDU
		i_instruction = `LEN'b00000000000000010010000000100001; //opcode = 0, rs = 0, rt = 1, rd = 4, shamp = 0, function = ADDU

		#15

		i_instruction = `LEN'b00000000011001100011000000100001;//opcode = 0, rs = 3, rt = 6, rd = 6, shamp = 0, function = ADDU

		// #20
		// reset = 1;
	end

	always 
		#5 clk = ~clk;


endmodule
