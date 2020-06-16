`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2020 17:55:03
// Design Name: 
// Module Name: HAZARD_DETECTION
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



module HAZARD_DETECTION #(
	parameter len = 32,
	parameter NB = $clog2(len)
	)(
	input i_memRead_IDEX,
	input [NB-1:0] i_rt_IDEX,
	input [NB-1:0] i_rs_IFID,
	input [NB-1:0] i_rt_IFID,

	output o_stallFlag
    );


	assign o_stallFlag = ( i_memRead_IDEX == 1 & ( (i_rt_IDEX == i_rs_IFID) | (i_rt_IDEX == i_rt_IFID) ) ) ?
								1 : 0;
endmodule

