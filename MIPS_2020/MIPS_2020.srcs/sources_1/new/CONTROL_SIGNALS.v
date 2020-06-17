`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.06.2020 19:38:04
// Design Name: 
// Module Name: CONTROL_SIGNALS
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



module CONTROL_SIGNALS#(
	parameter LEN_EXEC_BUS = 11,
	parameter LEN_MEM_BUS = 9,
	parameter LEN_WB_BUS = 2
	)(
    input [5:0] i_opCode,
    input [5:0] i_opCodeFunction,

    // junto las salidas en buses para mas prolijidad
    output reg [LEN_EXEC_BUS-1:0] o_signalControlEX,
    	// Jump&Link, JALOnly, RegDst, ALUSrc1, ALUSrc2, jump, jump register, ALUCode [4]
    output reg [LEN_MEM_BUS-1:0] o_signalControlME,
    	// SB, SH, LB, LH, Unsigned, Branch, MemRead, MemWrite
    output reg [LEN_WB_BUS-1:0] o_signalControlWB
    	// RegWrite, MemtoReg
    );

	reg [2:0] r_aluOp;
	wire [3:0] w_aluCode;

	ALU_CONTROL #()
	ALU_CONTROL (.i_opCodeFunction(i_opCodeFunction), .i_aluOp(r_aluOp), 
				   .o_aluCode(w_aluCode));

	always @(*) 
	begin

		o_signalControlEX[3:0] = w_aluCode;

		case(i_opCode)
			6'b 000000 : 
			begin //R-type
				case(i_opCodeFunction)
					6'b000000, 6'b000010, 6'b000011 :
					begin //SHIFT CON SHAMT
						o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0011000;
						r_aluOp <= 3'b000;
						o_signalControlME <= 9'b000000000;
						o_signalControlWB <= 2'b10;
					end
					6'b001000 :
					begin //JR
						o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000001;
						r_aluOp <= 3'b000;
						o_signalControlME <= 9'b000000000;
						o_signalControlWB <= 2'b00; // dudoso 2'b10
					end
					6'b001001 :
					begin //JALR
						o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b1010001;
						r_aluOp <= 3'b000;
						o_signalControlME <= 9'b000000000;
						o_signalControlWB <= 2'b10;
					end
					default:
					begin
						o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0010000;
						r_aluOp <= 3'b000;
						o_signalControlME <= 9'b000000000;
						o_signalControlWB <= 2'b10;
					end
				endcase
			end
			// LOADS
			6'b100000:
			begin //LB
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000100010;
				o_signalControlWB <= 2'b11;
			end
			6'b100001:
			begin //LH
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000010010;
				o_signalControlWB <= 2'b11;
			end
			6'b100011, 6'b100111:
			begin //LW, LWU
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000000010;
				o_signalControlWB <= 2'b11;
			end
			6'b100100:
			begin //LBU
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000101010;
				o_signalControlWB <= 2'b11;
			end
			6'b100101:
			begin //LHU
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000011010;
				o_signalControlWB <= 2'b11;
			end
			//STORES
			6'b101000:
			begin //SB
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b010000001;
				o_signalControlWB <= 2'b00;
			end
			6'b101001:
			begin //SH
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b001000001;
				o_signalControlWB <= 2'b00;
			end
			6'b101011 :
			begin //SW
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000000001;
				o_signalControlWB <= 2'b00;
			end
			6'b001000 :
			begin //ADDI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b10;
			end
			6'b001100 :
			begin //ANDI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b010;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b10;
			end
			6'b001101 :
			begin //ORI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b011;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b10;
			end
			6'b001110 :
			begin //XORI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b100;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b10;
			end
			6'b001111 :
			begin //LUI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b111;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b10;
			end
			6'b001010 :
			begin //SLTI
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000100;
				r_aluOp <= 3'b110;
				o_signalControlME <= 9'b000000000;
				o_signalControlWB <= 2'b10;
			end
			6'b 000100:
			begin //BRANCH on equal
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000000;
				r_aluOp <= 3'b110;
				o_signalControlME <= 9'b000000100;
				o_signalControlWB <= 2'b00;
			end
			6'b 000101:
			begin //BRANCH on not equal
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000000;
				r_aluOp <= 3'b110;
				o_signalControlME <= 9'b100000100;
				o_signalControlWB <= 2'b00;
			end
			6'b000010 :
			begin //JUMP
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000010;
				r_aluOp <= 3'b000;
				o_signalControlME <= 9'b000000000;
				o_signalControlWB <= 2'b00;
			end
			6'b000011 :
			begin //JAL
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b1100010;
				r_aluOp <= 3'b001;
				o_signalControlME <= 9'b000000000;
				o_signalControlWB <= 2'b10;
			end
			default: 
			begin
				o_signalControlEX[LEN_EXEC_BUS-1:4] <= 7'b0000000;
				r_aluOp <= 3'b000;
				o_signalControlME <= 9'b000000000;
				o_signalControlWB <= 2'b00;
			end		
		endcase
	end

endmodule

