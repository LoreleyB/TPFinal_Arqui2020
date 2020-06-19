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
	//input ctrl_clk_mips,
	input reset,
	//input [2:0] i_PC_src,
	input i_PC_src,
	//input [len-1:0] in_pc_jump,
	input [len-1:0] i_PC_branch,
	//input [len-1:0] in_pc_register,
	input stall_flag,

	input [len-1:0] i_address_debug,
	input debug_flag,
	input [len-1:0] i_instruc_to_memo,
	input i_write_enable_ram_inst,

	output reg [len-1:0] o_pc_branch,
	output [len-1:0] o_instruction,
	output [len-1:0] o_PC,
	output reg o_halt_flag_if // para debug
    );

    wire [len-1:0] connect_sumador_mux; 
    wire [len-1:0] connect_mux_pc;
    wire [len-1:0] connect_pc_sumador_mem;
    wire [len-1:0] connect_out_instruction;
    wire [len-1:0] connect_pc_out;
    wire w_validI;
    //wire flush = i_PC_src[0];
    wire flush = i_PC_src;

    assign o_instruction = connect_out_instruction;
    assign o_PC = connect_pc_sumador_mem;

	PC_MUX #(
		.len(len)
		)
		PC_MUX(
			//.jump(in_pc_jump),
			.branch(in_pc_branch),
			//.register(in_pc_register),
			.i_PC(connect_sumador_mux),
			.i_select(i_PC_src),
			.o_PC_MUX(connect_mux_pc)
		); 

	PC #(
		.len(len)
		)
		PC(
			.i_PC((w_validI)?(connect_pc_sumador_mem):(connect_mux_pc)),
			.clk(clk),
			.reset(reset),
			.enable(stall_flag),
			.o_PC(connect_pc_sumador_mem)
			);

	INSTRUCTION_RAM #(
		.RAM_WIDTH(len),
		.RAM_DEPTH(2048),
		// .INIT_FILE("/home/facundo/Desktop/practico_arquitectura_de_computadoras/TP4_MIPS/program.hex"),
		// .INIT_FILE("/home/maguerreberry/practico_arquitectura_de_computadoras/TP4_MIPS/program.hex"),
        // .INIT_FILE("E:/Drive/Facultad/quinto/Arquitectura_de_Computadoras/TP4_MIPS/program.hex"),
		.RAM_PERFORMANCE("LOW_LATENCY")
		)
		INSTRUCTION_RAM(
			.i_addressI(debug_flag ? i_address_debug : connect_pc_sumador_mem),
			.clka(clk),
			.reset(reset),
			.enable(stall_flag),
			.i_writeEnable(i_write_enable_ram_inst),
			.o_validI(w_validI),
			.flush(flush),
			.o_dataI(connect_out_instruction),
			.i_dataI(i_instruc_to_memo)
			); 

	PC_SUM #(
		.LEN(len)
		)
		PC_SUM(
			.i_inPC(connect_pc_sumador_mem),
			.o_outPC(connect_sumador_mux)
			); 


	always @(posedge clk, posedge reset) 
	begin
		if(reset) begin
			o_pc_branch <= 0;
			o_halt_flag_if <= 0;			
		end

        //else if (ctrl_clk_mips) begin
        else begin
            o_halt_flag_if <= w_validI;
    
            if (stall_flag | flush) 
            begin
                o_pc_branch <= (flush) ? {len{1'b 0}} : connect_sumador_mux;
            end
        end
    end
	
endmodule
