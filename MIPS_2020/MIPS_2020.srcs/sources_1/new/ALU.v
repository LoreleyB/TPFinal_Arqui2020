`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2020 19:17:57
// Design Name: 
// Module Name: ALU
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



module ALU #(
	parameter lenghtIN = 32,
	parameter lenghtOP = 4
	)(
	
	input signed [lenghtIN-1 : 0] i_dataA,
	input signed [lenghtIN-1 : 0] i_dataB,
	input signed [lenghtOP-1 : 0] i_opCode,

	output reg [lenghtIN - 1 : 0] o_result,
	output reg o_zeroFlag	
//	//inputs
//	i_dataA,
//	i_dataB,
//	i_opCode,

//	//output
//	o_result,
//	o_zeroFlag
    );

//	input signed [lenghtIN-1 : 0] i_dataA;
//	input signed [lenghtIN-1 : 0] i_dataB;
//	input signed [lenghtOP-1 : 0] i_opCode;

//	output reg [lenghtIN - 1 : 0] o_result;
//	output reg o_zeroFlag;

	always @(*)
	begin
		o_zeroFlag = 0;

		case (i_opCode)
			4'b 0000: o_result = i_dataB << i_dataA; //shift left
			4'b 0001: o_result = i_dataB >> i_dataA; //shift right logico
			4'b 0010: o_result = i_dataB >>> i_dataA; //shift right aritmetico
			4'b 0011: o_result = i_dataA + i_dataB; //add
			
			4'b 0100: 
			begin
				o_result = i_dataA < i_dataB; //slt, compare, si a < b, result = 1 
				o_zeroFlag = i_dataA == i_dataB ? 1 : 0; //BRANCH
			end

			4'b 0101: o_result = i_dataA & i_dataB; //and
			4'b 0110: o_result = i_dataA | i_dataB; //or
			4'b 0111: o_result = i_dataA ^ i_dataB; //xor
			4'b 1000: o_result = ~(i_dataA | i_dataB); //nor
			4'b 1001: o_result = i_dataB << 16; //LUI
			4'b 1010: o_result = i_dataA - i_dataB; //sub
			
			default: o_result = 0;
		endcase	
	end
endmodule	
