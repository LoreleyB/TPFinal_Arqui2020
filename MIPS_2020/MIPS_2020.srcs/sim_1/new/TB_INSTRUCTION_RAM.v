`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2020 19:18:29
// Design Name: 
// Module Name: TB_INSTRUCTION_RAM
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



`define len 32
`define NB $clog2(`len)

module TB_INSTRUCTION_RAM(
    );

	reg CLK100MHZ;
	reg i_writeEnable;
	reg [31:0] i_addressI;
	//reg [31:0] o_dataI;
	

	INSTRUCTION_RAM #(
		.RAM_WIDTH(`len),
		.RAM_DEPTH(2048),
		 .INIT_FILE("C:/Arquitectura/TPFinal_Arqui2020/MIPS_2020/program.hex"),
		.RAM_PERFORMANCE("LOW_LATENCY")
		)
		INSTRUCTION_RAM(
			.i_addressI(i_addressI),
			.clka(CLK100MHZ),
			.reset(),
			.enable(1),
			//.o_dataI(o_dataI)
			.i_writeEnable(i_writeEnable)
			//.i_dataI(i_dataI)
			); 	


	initial begin

		CLK100MHZ = 0;

		#10

		i_addressI = 0;
		i_writeEnable = 0;
		//i_dataI = 1;

	end

	always
		#5 CLK100MHZ = ~CLK100MHZ;
		
endmodule
    