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
	input [2:0] i_PC_src,
	//input [len-1:0] in_pc_jump,
	input [len-1:0] i_PC_branch,
	//input [len-1:0] in_pc_register,
	input stall_flag,

	input [len-1:0] in_addr_debug,
	input debug_flag,
	input [len-1:0] in_ins_to_mem,
	input wea_ram_inst,

	output reg [len-1:0] out_pc_branch,
	output [len-1:0] out_instruction,
	output [len-1:0] out_pc,
	output reg out_halt_flag_if // para debug
    );

    wire [len-1:0] connect_sumador_mux; 
    wire [len-1:0] connect_mux_pc;
    wire [len-1:0] connect_pc_sumador_mem;
    wire [len-1:0] connect_out_instruction;
    wire [len-1:0] connect_pc_out;
    wire connect_wire_douta;
    wire flush = i_PC_src[0];

    assign out_instruction = connect_out_instruction;
    assign out_pc = connect_pc_sumador_mem;

	mux_PC #(
		.len(len)
		)
		u_mux_PC(
			.jump(in_pc_jump),
			.branch(i_PC_branch),
			.register(in_pc_register),
			.pc(connect_sumador_mux),
			.select(i_PC_src),
			.out_mux_PC(connect_mux_pc)
		); 

	pc #(
		.len(len)
		)
		u_pc(
			.In((connect_wire_douta)?(connect_pc_sumador_mem):(connect_mux_pc)),
			.clk(clk),
			.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.enable(stall_flag),
			.Out(connect_pc_sumador_mem)
			);

	ram_instrucciones #(
		.RAM_WIDTH(len),
		.RAM_DEPTH(2048),
		// .INIT_FILE("/home/facundo/Desktop/practico_arquitectura_de_computadoras/TP4_MIPS/program.hex"),
		// .INIT_FILE("/home/maguerreberry/practico_arquitectura_de_computadoras/TP4_MIPS/program.hex"),
        // .INIT_FILE("E:/Drive/Facultad/quinto/Arquitectura_de_Computadoras/TP4_MIPS/program.hex"),
		.RAM_PERFORMANCE("LOW_LATENCY")
		)
		u_ram_instrucciones(
			.addra(debug_flag ? in_addr_debug : connect_pc_sumador_mem),
			.clka(clk),
			.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.ena(stall_flag),
			.wea(wea_ram_inst),
			.wire_douta(connect_wire_douta),
			.flush(flush),
			.douta(connect_out_instruction),
			.dina(in_ins_to_mem)
			); 

	sumador #(
		.len1(len)
		)
		u_sumador(
			.In1(connect_pc_sumador_mem),
			.In2(1),
			.Out(connect_sumador_mux)
			); 


	always @(posedge clk, posedge reset) 
	begin
		if(reset) begin
			out_pc_branch <= 0;
			out_halt_flag_if <= 0;			
		end

		else if (ctrl_clk_mips) begin
			out_halt_flag_if <= connect_wire_douta;

			if (stall_flag | flush) 
			begin
				out_pc_branch <= (flush) ? {len{1'b 0}} : connect_sumador_mux;
			end
		end
	end
	
endmodule
