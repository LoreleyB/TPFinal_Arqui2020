`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2020 19:29:45
// Design Name: 
// Module Name: FORWARDING_UNIT
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



module FORWARDING_UNIT #(
	parameter len = 32,
	parameter NB = $clog2(len)
	)(
	input i_registerWrite_EXMEM,	// flag
	input i_registerWrite_MEMWB,	// flag
	input [NB-1:0] i_rd_EXMEM,		// registro ya calculado, a forwardear
	input [NB-1:0] i_rd_MEMWB,		// registro ya calculado, a forwardear
	input [NB-1:0] i_rs_IDEX,		// registro de instr siguiente que puede necesitar forwarding
	input [NB-1:0] i_rt_IDEX,		// registro de instr siguiente que puede necesitar forwarding
    
	output reg [1:0] o_controlFWMuxA,	// control mux entrada A de la ALU 
	output reg [1:0] o_controlFWMuxB 	// control mux entrada B de la ALU
    );

	always @(*) begin
	   //para registro rs, mux A
        //si inst i-2 escribe en registro y rd de inst i-2 = rs de inst i y (inst i-1 NO escribe en registro o rd de inst i-1
        // sea distinto del rs de isnt i)  
		if((i_registerWrite_MEMWB == 1 & i_rd_MEMWB != 0) & i_rd_MEMWB == i_rs_IDEX & ((i_registerWrite_EXMEM == 0 & i_rd_EXMEM != 0) | i_rd_EXMEM != i_rs_IDEX))
			o_controlFWMuxA <= 2'b10;
		//si inst i-1 escribe en registro y rd de inst i-1 = rs de inst i	
		else if (i_registerWrite_EXMEM == 1 & i_rd_EXMEM == i_rs_IDEX)
			o_controlFWMuxA <= 2'b01;
		else
			o_controlFWMuxA <= 2'b00;

        //idem para registro rt, mux B
		if((i_registerWrite_MEMWB == 1 & i_rd_MEMWB != 0) & i_rd_MEMWB == i_rt_IDEX & ((i_registerWrite_EXMEM == 0 & i_rd_EXMEM != 0) | i_rd_EXMEM != i_rt_IDEX))
			o_controlFWMuxB <= 2'b10;
		else if (i_registerWrite_EXMEM == 1 & i_rd_EXMEM == i_rt_IDEX)
			o_controlFWMuxB <= 2'b01;
		else
			o_controlFWMuxB <= 2'b00;
	end

endmodule
