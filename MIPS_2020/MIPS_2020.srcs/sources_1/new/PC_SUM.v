`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2020 19:50:00
// Design Name: 
// Module Name: PC_SUM
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


module PC_SUM #(
	parameter LEN = 32 // tener en cuenta que en el In1 simepre va la entrada mas grande
    ) (
    input [LEN-1:0] i_inPC,
    //input In2,
    output [LEN-1:0] o_outPC
    );

    assign o_outPC = i_inPC + 1'b1; 

    // always@(*)
    // begin
    //   Out = In1 + In2;
    // end

endmodule
