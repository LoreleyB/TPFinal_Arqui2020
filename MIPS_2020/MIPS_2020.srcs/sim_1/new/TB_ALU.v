`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2020 19:45:43
// Design Name: 
// Module Name: TB_ALU
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



`define lenghtIN 32
`define lenghtOP 4

module TB_ALU(
    );
	
	reg [`lenghtIN-1 : 0] i_dataA;
	reg [`lenghtIN-1 : 0] i_dataB;
	reg [`lenghtOP-1 : 0] i_opCode;
	reg CLK100MHZ;

	ALU #(.lenghtIN(`lenghtIN), .lenghtOP(`lenghtOP))
	ALU(
		.i_dataA(i_dataA),
		.i_dataB(i_dataB),
		.i_opCode(i_opCode)
		);

	initial begin
		CLK100MHZ = 0;

		i_dataA = `lenghtIN'h3;
		i_dataB = `lenghtIN'h15;//21
		i_opCode = `lenghtOP'b0000; //shift left

		#10

		i_dataA = `lenghtIN'h2;
		i_dataB = `lenghtIN'h15;
		i_opCode = `lenghtOP'b0001; //shift right logico

		#10

		i_dataA = `lenghtIN'h2;
		i_dataB = -`lenghtIN'h15;
		i_opCode = `lenghtOP'b0010; //shift right aritmetico

		#10

		i_dataA = `lenghtIN'h10;
		i_dataB = `lenghtIN'h20;
		i_opCode = `lenghtOP'b0011; //add

		#10

		i_dataA = `lenghtIN'h2;
		i_dataB = -`lenghtIN'h15;
		i_opCode = `lenghtOP'b0100; //slt compare

		#10

		i_dataA = `lenghtIN'hF0;
		i_dataB = `lenghtIN'hE4;
		i_opCode = `lenghtOP'b0101; //and

		#10

		i_dataA = `lenghtIN'h0F;
		i_dataB = `lenghtIN'h41;
		i_opCode = `lenghtOP'b0110; //or

		#10

		i_dataA = `lenghtIN'hFB;
		i_dataB = `lenghtIN'h64;
		i_opCode = `lenghtOP'b0111; //xor


		#10

		i_dataA = `lenghtIN'hFF;
		i_dataB = `lenghtIN'hFF;
		i_opCode = `lenghtOP'b0100; //slt compare


		#10

		i_dataA = `lenghtIN'hF0;
		i_dataB = `lenghtIN'h31;
		i_opCode = `lenghtOP'b1000; //nor
		#10

		i_dataA = `lenghtIN'h4;
		i_dataB = `lenghtIN'h5;
		i_opCode = `lenghtOP'b0100; //slt compare
		#10

		i_dataA = `lenghtIN'h15;
		i_dataB = `lenghtIN'h10;
		i_opCode = `lenghtOP'b1010; //sub

	end

	always
		#5 CLK100MHZ = ~CLK100MHZ;
		
endmodule
