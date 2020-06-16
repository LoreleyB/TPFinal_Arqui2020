`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2020 18:20:37
// Design Name: 
// Module Name: IDECODE
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



module IDECODE #(
	parameter len = 32,
	parameter NB = $clog2(len),
	parameter len_exec_bus = 11,
	parameter len_mem_bus = 9,
	parameter len_wb_bus = 2
	)(
	input clk,
	//input ctrl_clk_mips,
	input reset,
	input [len-1:0] in_pc_branch,
	input [len-1:0] i_instruction,
	input RegWrite,
	input [len-1:0] write_data,
	input [NB-1:0] write_register,
	input flush,
	input halt_flag_d,

	output reg [len-1:0] out_pc_branch,
	output [len-1:0] out_pc_jump,	
	output [len-1:0] out_pc_jump_register,	
	output [len-1:0] out_reg1,
	output [len-1:0] out_reg2,
	output reg [len-1:0] out_sign_extend,
	output reg [NB-1:0] out_rt,
	output reg [NB-1:0] out_rd,
	output reg [NB-1:0] out_rs,
	output reg [NB-1:0] out_shamt,

	output [len-1:0] out_reg1_recolector,	// para recolector en modo debug
	output reg out_halt_flag_d,

	// señales de control
	output flag_jump,
	output flag_jump_register,
	output reg [len_exec_bus-1:0] execute_bus,
	output reg [len_mem_bus-1:0] memory_bus,
	output reg [len_wb_bus-1:0] writeBack_bus,

	//señal de control de riesgos
	output stall_flag
    );

	wire [len_exec_bus-1:0] connect_execute_bus;
	wire [len_mem_bus-1:0] connect_memory_bus ;
	wire [len_wb_bus-1:0] connect_writeBack_bus;	

	wire [len-1:0] 	connect_out_wire_reg1,
					connect_out_reg1,
					connect_out_reg2;

    wire mux_control;
    wire [(len_exec_bus+len_wb_bus+len_mem_bus)-1:0] mux_out = mux_control ? 0 : {connect_execute_bus, connect_memory_bus, connect_writeBack_bus};

	assign flag_jump = (flush) ? (0) : (connect_execute_bus[5]);
	assign flag_jump_register = (flush) ? (0) : (connect_execute_bus[4]);
	
	assign out_pc_jump = (flush) ? (0) : ({in_pc_branch[31:28], {2'b 00, (i_instruction[25:0])}});
	assign out_pc_jump_register = (flush) ? (0) : (connect_out_wire_reg1);

	assign out_reg1_recolector = connect_out_wire_reg1; // para recolector en modo debug
	
    assign out_reg1 = (flush) ? (0) : (connect_out_reg1); 
    assign out_reg2 = (flush) ? (0) : (connect_out_reg2);

    assign stall_flag = (flush) ? (0) : (mux_control);

	CONTROL_SIGNAL #()
		CONTROL_SIGNAL(
			.i_opCode(i_instruction[31:26]),
			.i_opCodeFunction(i_instruction[5:0]),
			.o_executeBus(connect_execute_bus),
			.o_memoryBus(connect_memory_bus),
			.o_writeBackBus(connect_writeBack_bus)
			);

	RW_REGISTERS #(
		.width(32),
		.lenght(32),
		.NB($clog2(len))
		)
		RW_REGISTERS(
			.clk(clk),
			//.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.i_regWrite(RegWrite),
			.i_readRegister1(i_instruction[25:21]),
			.i_readRegister2(i_instruction[20:16]),
			.i_writeRegister(write_register),
			.i_writeData(write_data),

			.o_wireReadData1(connect_out_wire_reg1),
			.o_readData1(connect_out_reg1),
			.o_readData2(connect_out_reg2)
			);

	HAZARD_DETECTION #(
		.len(32)
		)
		HAZARD_DETECTION(
			.i_memRead_IDEX(memory_bus[1]),
			.i_rt_IDEX(out_rt),
			.i_rs_IFID(i_instruction [25:21]),
			.i_rt_IFID(i_instruction [20:16]),

			.o_stallFlag(mux_control)
			);

	always @(posedge clk, posedge reset) 
	begin
		if (reset) begin
			out_pc_branch <= 0;
			out_sign_extend <= 0;
			out_rt <= 0;
			out_rd <= 0;
			out_rs <= 0;
			out_shamt <= 0;
			execute_bus <= 0;
			memory_bus <= 0;
			writeBack_bus <= 0;
			out_halt_flag_d <= 0;
		end

		else if(ctrl_clk_mips) begin
			out_halt_flag_d <= halt_flag_d;

			if(flush)
			begin
				out_pc_branch <= 0;
				out_sign_extend <= 0;
				out_rt <= 0;
				out_rd <= 0;
				out_rs <= 0;
				out_shamt <= 0;
				execute_bus <= 0;
				memory_bus <= 0;
				writeBack_bus <= 0;
			end
			else 
			begin			
				out_pc_branch <= in_pc_branch;
				out_sign_extend <= $signed(i_instruction[15:0]);
				out_rt <= i_instruction [20:16];
				out_rd <= i_instruction [15:11];
				out_rs <= i_instruction [25:21];
				out_shamt <= i_instruction [10:6];
				execute_bus <= mux_out[(len_mem_bus+len_wb_bus+len_exec_bus)-1:len_mem_bus+len_wb_bus];
				memory_bus <= mux_out[(len_mem_bus+len_wb_bus)-1:len_wb_bus];
				writeBack_bus <= mux_out[len_wb_bus-1:0];		
			end	
		end
	end

endmodule