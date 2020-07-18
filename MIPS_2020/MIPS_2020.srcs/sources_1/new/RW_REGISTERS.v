`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2020 17:29:06
// Design Name: 
// Module Name: RW_REGISTERS
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


module RW_REGISTERS#(
	parameter width = 32,
	parameter lenght = 32,
	parameter NB = $clog2(lenght)//5 bits
	)(
	input clk,
	
	input reset,
	input i_flagRegWrite,
	input [NB-1:0] i_readRegister1,
	input [NB-1:0] i_readRegister2,
	input [NB-1:0] i_writeRegister,
	input [width-1:0] i_writeData,
	input enable, //step by step

	output [width-1:0] o_wireReadData1,
	output reg [width-1:0] o_readData1,
	output reg [width-1:0] o_readData2
    );

	reg [width-1:0]  r_dataRegistersMatrix [lenght-1:0];

	assign o_wireReadData1 = r_dataRegistersMatrix[i_readRegister1];

	generate
		integer ii;		
		initial
        for (ii = 0; ii < lenght; ii = ii + 1)
          r_dataRegistersMatrix[ii] = {width{1'b0+(ii)}};//?????
	endgenerate

	always @(posedge clk)
	begin
		if (reset)
		begin
			o_readData1 = 0;
			o_readData2 = 0;
		end

		
		else if (enable) begin
			o_readData1 <= r_dataRegistersMatrix[i_readRegister1];
			o_readData2 <= r_dataRegistersMatrix[i_readRegister2];
		end
	end

	always @(negedge clk)
	begin
		
			if (i_flagRegWrite) 
			begin
				if (enable) begin
				    r_dataRegistersMatrix[i_writeRegister] <= i_writeData;
				end				
			end
		
	end

endmodule
