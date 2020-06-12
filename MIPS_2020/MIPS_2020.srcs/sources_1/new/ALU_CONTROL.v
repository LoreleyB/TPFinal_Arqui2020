`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2020 19:28:57
// Design Name: 
// Module Name: ALU_CONTROL
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


module ALU_CONTROL(
    input [5:0] i_opCodeFunction,
    input [2:0] i_aluOp,

    output reg [3:0] o_aluCode
    );

	always @(*) 
	begin
		case(i_aluOp)
			3'b000 : 
			begin //R-type
				case(i_opCodeFunction)
					6'b000000 : o_aluCode <= 4'b0000; // sll
					6'b000010 : o_aluCode <= 4'b0001; // srl
					6'b000011 : o_aluCode <= 4'b0010; // sra
					6'b000100 : o_aluCode <= 4'b0000; // sllv
					6'b000110 : o_aluCode <= 4'b0001; // srlv
					6'b000111 : o_aluCode <= 4'b0010; // srav
					6'b100001 : o_aluCode <= 4'b0011; // addu
					6'b100011 : o_aluCode <= 4'b1010; // subu
					6'b100100 : o_aluCode <= 4'b0101; // and
					6'b100101 : o_aluCode <= 4'b0110; // or
					6'b100110 : o_aluCode <= 4'b0111; // xor
					6'b100111 : o_aluCode <= 4'b1000; // nor
					6'b101010 :	o_aluCode <= 4'b0100; // slt
					6'b001001 :	o_aluCode <= 4'b0011; // sumar
					default : o_aluCode <= 4'b0000;
				endcase
			end			
			3'b001 : o_aluCode <= 4'b0011; //sumar
			3'b010 : o_aluCode <= 4'b0101; //and
			3'b011 : o_aluCode <= 4'b0110; //or
			3'b100 : o_aluCode <= 4'b0111; //xor
			3'b101 : o_aluCode <= 4'b0000; //shift left
			3'b110 : o_aluCode <= 4'b0100; //compare 
			3'b111 : o_aluCode <= 4'b1001; // INSTRUCCION LUI -> SHIFT 16 IZQUIERDA
			default: o_aluCode <= 4'b0000;	
		endcase
	end

endmodule
