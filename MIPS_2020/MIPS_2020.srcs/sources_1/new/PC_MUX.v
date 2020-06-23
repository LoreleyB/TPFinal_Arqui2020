`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2020 20:31:20
// Design Name: 
// Module Name: PC_MUX
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


module PC_MUX #(
	parameter len = 32
	) (
	input [len-1:0] i_jump,
	input [len-1:0] i_branch,
	input [len-1:0] i_register,
	input [len-1:0] i_PC,
	input [2:0] i_select,
	output reg [len-1:0] o_PC_MUX
    );

    always @(*) 
    begin
    	case (i_select)
    		3'b 100: o_PC_MUX <= i_jump;
    		3'b 010: o_PC_MUX <= i_register;
    		3'b 001: o_PC_MUX <= i_branch;
    		default: o_PC_MUX <= i_PC; 
    	endcase    

   	end
	    
endmodule
