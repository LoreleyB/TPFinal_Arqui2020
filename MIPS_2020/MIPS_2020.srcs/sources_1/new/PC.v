`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2020 20:27:20
// Design Name: 
// Module Name: PC
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



module PC#(
    parameter len = 32
    ) (
    input [len-1:0] i_PC,//entrada del PC (posición en la memoria de instrucción)
    input clk,
    input reset,
    input enable,
   

    output reg [len-1:0] o_PC = 0
    );

    always @(posedge clk, posedge reset)
    begin
        if(reset) begin
            o_PC = {len{1'b 0}}; 
        end
		else if (enable) begin
            
                o_PC = i_PC;
            end

        else begin
                o_PC = o_PC;
            end
        end
//	end

endmodule

