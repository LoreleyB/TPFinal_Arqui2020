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
	//input [len-1:0] jump,
	input [len-1:0] i_branch,
	//input [len-1:0] register,
	input [len-1:0] i_pc,
	input i_select,
	output reg [len-1:0] o_PC_MUX
    );

    always @(*) 
    begin
    	if(i_select)
    		//3'b 100: out_mux_PC <= jump;
    		//3'b 010: out_mux_PC <= register;
    	   o_PC_MUX <= i_branch;
    	else
    	   o_PC_MUX <= i_pc;
   	end
	    
endmodule
