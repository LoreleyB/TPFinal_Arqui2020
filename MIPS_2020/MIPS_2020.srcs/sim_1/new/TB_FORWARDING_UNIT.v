`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.06.2020 11:02:23
// Design Name: 
// Module Name: TB_FORWARDING_UNIT
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

module TB_FORWARDING_UNIT(
    );
	
	reg i_registerWrite_EXMEM;
	reg i_registerWrite_MEMWB;
	reg [`NB-1:0] i_rd_EXMEM;
	reg [`NB-1:0] i_rd_MEMWB;
	reg [`NB-1:0] i_rs_IDEX;
	reg [`NB-1:0] i_rt_IDEX;
	reg CLK100MHZ;

	FORWARDING_UNIT #(.lenghtIN(`len), .NB(`NB))
	FORWARDING_UNIT(
		.i_registerWrite_EXMEM(i_registerWrite_EXMEM),
		.i_registerWrite_MEMWB(i_registerWrite_MEMWB),
		.i_rd_EXMEM(i_rd_EXMEM),
		.i_rd_MEMWB(i_rd_MEMWB),
		.i_rs_IDEX(i_rs_IDEX),
		.i_rt_IDEX(i_rt_IDEX)
		);

	initial begin
		CLK100MHZ = 0;

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 0;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 0;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 1;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 1;
		
		i_rs_IDEX = 0;

		#10

		i_registerWrite_EXMEM = 1;
		i_registerWrite_MEMWB = 1;
		i_rd_EXMEM = 0;
		i_rd_MEMWB = 0;
		
		i_rs_IDEX = 0;

	end

	always
		#5 CLK100MHZ = ~CLK100MHZ;
		
endmodule
