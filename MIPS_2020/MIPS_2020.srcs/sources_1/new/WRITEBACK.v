`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2020 18:46:24
// Design Name: 
// Module Name: WRITEBACK
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


module WRITEBACK #(
    parameter len = 32
	) (
	input i_memToReg,
	input [len-1:0] i_aluOut,
	input [len-1:0] i_memOut,
	output [len-1:0] o_dataRegister
    );

    //always @(*)
    //begin
        assign o_dataRegister = (i_memToReg) ? i_memOut : i_aluOut;
    //end
endmodule
