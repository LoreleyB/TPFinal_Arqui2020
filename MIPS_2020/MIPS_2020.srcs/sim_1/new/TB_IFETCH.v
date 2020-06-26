`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2020 18:35:41
// Design Name: 
// Module Name: TB_IFETCH
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

module TB_IFETCH(

    );
	
	reg clk;
	reg reset;
	//reg in_pc_enable;
	reg [2:0] i_pcSrc;
	reg i_stallFlag;
	//reg [`LEN-1:0] i_pcBranch;
	//wire [`LEN-1:0] o_pcBranch;
	wire [`LEN-1:0] o_PC;
	wire [`LEN-1:0] o_instruction;
	
	IFETCH #(
		.len(`LEN)	
		)
		IFETCH (
			.clk(clk),
			.reset(reset),
			.i_pcSrc(i_pcSrc),
			//.i_pcBranch(i_pcBranch),
			//.o_pcBranch(o_pcBranch),
			.i_stallFlag (i_stallFlag),
			.o_instruction(o_instruction),
			.o_PC(o_PC)
		);

	initial
	begin
		clk = 0;
		reset = 1;
		#15
		reset = 0;
		i_stallFlag = 1'b1;
		i_pcSrc = 3'b000;
	end

	always 
		#5 clk = ~clk;


endmodule