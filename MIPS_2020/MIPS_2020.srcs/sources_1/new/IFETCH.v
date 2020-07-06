`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.06.2020 20:26:05
// Design Name: 
// Module Name: IFETCH
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


module IFETCH #(
	parameter len = 32
	) (
	input clk,
	
	input reset,
	input [2:0] i_pcSrc,
	input [len-1:0] i_pcJump,
	input [len-1:0] i_pcBranch,
	input [len-1:0] i_pcRegister,
	input i_stallFlag, //cargar PC y lectura de isntruccion

	output reg [len-1:0] o_pcBranch,
	output [len-1:0] o_instruction,
	output [len-1:0] o_PC,
	output reg o_haltFlag_IF
    );

    wire [len-1:0] w_pcSumadorMux; 
    wire [len-1:0] w_muxPc;
    wire [len-1:0] w_pctoSumadorMem;
    wire [len-1:0] w_instruction;
    wire w_validI;
    wire w_flush = i_pcSrc[0];
    //wire w_flush = i_pcSrc;

    assign o_instruction = w_instruction;
    assign o_PC = w_pctoSumadorMem;

	PC_MUX #(
		.len(len)
		)
		PC_MUX(
			.i_jump(i_pcJump),
			.i_branch(i_pcBranch),
			.i_register(i_pcRegister),
			.i_PC(w_pcSumadorMux),
			.i_select(i_pcSrc),
			.o_PC_MUX(w_muxPc)
		); 

	PC #(
		.len(len)
		)
		PC(
			.i_PC((w_validI)?(w_pctoSumadorMem):(w_muxPc)),
			.clk(clk),
			.reset(reset),
			.enable(i_stallFlag),
			.o_PC(w_pctoSumadorMem)
			);

	INSTRUCTION_RAM #(
		.RAM_WIDTH(len),
		.RAM_DEPTH(2048),
		 .INIT_FILE("C:/Arquitectura/TPFinal_Arqui2020/MIPS_2020/program.hex")
		//.RAM_PERFORMANCE("LOW_LATENCY")
		)
		INSTRUCTION_RAM(
			.i_addressI(w_pctoSumadorMem),
			.clka(clk),
			.reset(reset),
			.enable(i_stallFlag),
			.o_validI(w_validI),
			.i_flush(w_flush),
			.o_dataI(w_instruction)
			); 

	PC_SUM #(
		.LEN(len)
		)
		PC_SUM(
			.i_inPC(w_pctoSumadorMem),
			.o_outPC(w_pcSumadorMux)
			); 


	always @(posedge clk, posedge reset) 
	begin
		if(reset) begin
			o_pcBranch <= 0;
			o_haltFlag_IF <= 0;			
		end

        
        else begin
            o_haltFlag_IF <= w_validI;
    
            if (i_stallFlag | w_flush) 
            begin
                o_pcBranch <= (w_flush) ? {len{1'b 0}} : w_pcSumadorMux;//si es una salto, mando 0, sino mando pc + 1
            end
        end
    end
	
endmodule
