`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.06.2020 18:11:25
// Design Name: 
// Module Name: MIPS
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



module MIPS#(
	parameter LEN = 32,
	parameter NB = $clog2(LEN),
	parameter len_exec_bus = 11,
	parameter len_mem_bus = 9,
	parameter len_wb_bus = 2,
    parameter nb_Latches_1_2 = (LEN*2),
    parameter nb_Latches_2_3 = (LEN*4),
    parameter nb_Latches_3_4 = (LEN*4),
    parameter nb_Latches_4_5 = (LEN*3)
	)(
	input clk,
	input reset,

	// para debug

	input i_debugFlag,
	input [LEN-1:0] i_addressDebug,
	input [LEN-1:0] i_addressMemInst,
	input [LEN-1:0] i_instructoMemo,
	input i_writeEnable_inst,
	//input ctrl_clk_mips,

	output [LEN-1:0] o_registerARecolector,
	output [LEN-1:0] o_wireMem,
	output [LEN-1:0] o_PC,
	output o_haltFlag,
    output [(nb_Latches_1_2)-1:0] o_latches_IFID,
    output [(nb_Latches_2_3)-1:0] o_latches_IDEX,
    output [(nb_Latches_3_4)-1:0] o_latches_EXMEM,
    output [(nb_Latches_4_5)-1:0] o_latches_MEMWB 
	);

    wire [LEN-1:0] w_pcBranch_IFID,
				   w_pcBranch_IDEX,
				   //w_pcBranch_EXIF,
				   w_pcJump,
				   w_pcJumpRegister,
				   w_instruccion,
				   w_registerDataA,
				   w_registerDataB,
				   w_signExtend,
				   w_aluResult,
				   w_writeData_WBID,  //y adem·s entra a los MUXA y MUXB determinados por FW
				   w_readData,
				   w_addressMem_aluResult,
				   w_writeData_EXMEM,
				   w_pcBranch_EXMEM,
				   w_pcBranch_MEMIF, //No deberia salir de DECODE????? esta saliendo de MEM y va a IF
				   w_registerARecolector,
				   w_wireMem,
				   w_PC;

	wire [NB-1:0] connect_rt,
				  connect_rd,
				  connect_rs,
				  connect_shamt,
				  connect_write_reg_3_4,
				  connect_write_reg_4_2;

    wire [len_exec_bus-1:0] connect_execute_bus;
	
	wire [len_mem_bus-1:0] connect_memory_bus_2_3,
			   connect_memory_bus_3_4;
	
	wire [len_wb_bus-1:0] connect_writeBack_bus_2_3,
			   connect_out_writeBack_bus,
			   connect_writeBack_bus_3_4;
    
    wire connect_flag_jump,
         connect_flag_jump_register,
	     connect_zero_flag,
	     connect_branch_flag,
	     connect_stall_flag,
	     connect_halt_flag_1_2,
	     connect_halt_flag_2_3,
	     connect_halt_flag_3_4,
	     w_haltFlag_MEWB; 

	assign w_writeData_WBID = (connect_out_writeBack_bus[0]) ? w_readData : w_addressMem_aluResult;//si MemtoReg=1 entoces toma dato de memoria, sino toma resultado de Alu, ultimo mux

	assign o_registerARecolector = w_registerARecolector;
	assign o_wireMem = w_wireMem;
	assign o_PC = w_PC;
	assign o_haltFlag = w_haltFlag_MEWB;

	assign o_latches_IFID = {	// 2 registros
		w_instruccion, // 32 bits
		w_pcBranch_IFID // 32 bits
	};
	assign o_latches_IDEX = {	// 4 registros
		{10{1'b 0}}, // 10 bits
		connect_execute_bus, // 11 bits
		connect_memory_bus_2_3, // 9 bits
		connect_writeBack_bus_2_3, // 2 bits
		{12{1'b 0}}, // 12 bits
		connect_rd, // 5 bits
		connect_rs, // 5 bits
		connect_rt, // 5 bits
		connect_shamt, // 5 bits
		w_signExtend, // 32 bits
		w_pcBranch_IDEX // 32 bits
	};
	assign o_latches_EXMEM = {	// 4 registros
		{15{1'b 0}}, // 15 bits
		connect_memory_bus_3_4, // 9 bits
		connect_writeBack_bus_3_4, // 2 bits
		connect_write_reg_3_4, // 5 bits
		connect_zero_flag, // 1 bit
		w_aluResult, // 32 bits
		w_pcBranch_EXMEM, // 32 bits
		w_registerDataB // 32 bits
	};
	assign o_latches_MEMWB = {	// 3 registros
		{24{1'b 0}}, // 24 bits
		w_haltFlag_MEWB, // 1 bit
		connect_write_reg_4_2, // 5 bits
		connect_out_writeBack_bus, // 2 bits
		w_addressMem_aluResult, // 32 bits
		w_readData // 32 bits
	};

	IFETCH #(
		.len(LEN)
		)
		IFETCH(
			.clk(clk),
			//.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.i_pcSrc({connect_flag_jump, connect_flag_jump_register, connect_branch_flag}),
			.i_pcJump(w_pcJump),
			.i_pcBranch(w_pcBranch_MEMIF),
			.i_pcRegister(w_pcJumpRegister),
			.i_stallFlag(!connect_stall_flag),

			.i_addressDebug(i_addressMemInst),
			.i_debugFlag(i_debugFlag),
			.i_instructoMemo(i_instructoMemo),
			.i_writeEnable_inst(i_writeEnable_inst),

			.o_pcBranch(w_pcBranch_IFID),
			.o_instruction(w_instruccion),
			.o_PC(w_PC), // para debug
			.o_haltFlag_IF(connect_halt_flag_1_2) // para debug
		);

	IDECODE #(
		.len(LEN)
		)
		IDECODE(
			.clk(clk),
			//.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.i_pcBranch(w_pcBranch_IFID),
			.i_instruction(i_debugFlag ? {{6{1'b0}}, i_addressDebug[4:0], {21{1'b0}}} : w_instruccion),
			.i_flagRegWrite(connect_out_writeBack_bus[1]),
			.i_writeData(w_writeData_WBID),
			.i_writeRegister(connect_write_reg_4_2),
			.i_flush(connect_branch_flag),
			.i_haltFlag_ID(connect_halt_flag_1_2),
			
			.o_pcBranch(w_pcBranch_IDEX),
			.o_pcJump(w_pcJump),
			.o_pcJumpRegister(w_pcJumpRegister),
			.o_registerDataA(w_registerDataA),
			.o_registerDataB(w_registerDataB),
			.o_signExtend(w_signExtend),
			.o_rt(connect_rt),
			.o_rd(connect_rd),
			.o_rs(connect_rs),
			.o_shamt(connect_shamt),

			.o_registerARecolector(w_registerARecolector),
            .o_haltFlag_ID(connect_halt_flag_2_3),
            

			.o_flagJump(connect_flag_jump),
			.o_flagJumpRegister(connect_flag_jump_register),
			.o_signalControlEX(connect_execute_bus),
            .o_signalControlME(connect_memory_bus_2_3),
			.o_signalControlWB(connect_writeBack_bus_2_3),

			.i_stallFlag(connect_stall_flag)

			
			
		);

	IEXECUTE #(
		.len(LEN)
		)
		IEXECUTE(
			.clk(clk),
			//.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
		
			.i_pcBranch(w_pcBranch_IDEX),
			.i_dataRegA(w_registerDataA),
			.i_dataRegB(w_registerDataB),
			.i_signExtend(w_signExtend),
			.i_rt(connect_rt),
			.i_rd(connect_rd),
			.i_shamt(connect_shamt),
		
			.i_signalControlEX(connect_execute_bus),
			.i_signalControlME(connect_memory_bus_2_3),
			.i_signalControlWB(connect_writeBack_bus_2_3), 

			.i_registerWrite_EXMEM(connect_writeBack_bus_3_4[1]),
			.i_registerWrite_MEMWB(connect_out_writeBack_bus[1]),
			.i_rd_EXMEM(connect_write_reg_3_4),
			.i_rd_MEMWB(connect_write_reg_4_2),
			.i_rs(connect_rs),

			.i_dataMEM_FW(w_aluResult),
			.i_dataWB_FW(w_writeData_WBID),
			.i_flush(connect_branch_flag),
		
		    .i_haltFlag_EX(connect_halt_flag_2_3),
			
			.o_pcBranch(w_pcBranch_EXMEM),
			.o_alu(w_aluResult),
			.o_zeroFlag(connect_zero_flag),
			.o_dataRegB(w_writeData_EXMEM),
			.o_writeReg(connect_write_reg_3_4),
		
			.o_haltFlag_EX(connect_halt_flag_3_4),
			
			// se√±ales de control
			.o_signalControlME(connect_memory_bus_3_4),
			.o_signalControlWB(connect_writeBack_bus_3_4)
			);

	IMEMORY #(
		.len(LEN)
		)
		IMEMORY(
			.clk(clk),
			//.ctrl_clk_mips(ctrl_clk_mips),
			.reset(reset),
			.i_addressMem(i_debugFlag ? i_addressDebug : w_aluResult),
			.i_writeData(w_writeData_EXMEM),
			
			.i_signalControlME(connect_memory_bus_3_4),
		    .i_signalControlWB(connect_writeBack_bus_3_4),
			.i_writeReg(connect_write_reg_3_4),			
			.i_zeroFlag(connect_zero_flag),
			.i_pcBranch(w_pcBranch_EXMEM),

			.i_haltFlag_MEM(connect_halt_flag_3_4),
			
			//outputs		
			.o_readData(w_readData),
			.o_pcSrc(connect_branch_flag),
			.o_pcBranch(w_pcBranch_MEMIF),
		    .o_signalControlWB(connect_out_writeBack_bus),
			.o_addressMem(w_addressMem_aluResult),//se usa como entrada al MUX de la etapa WB, es el resultado de la ALU. Ver de hacer la etapa WB
			.o_writeReg(connect_write_reg_4_2),

			.o_wireMem(w_wireMem), // para debug
			
			.o_haltFlag_MEM(w_haltFlag_MEWB)
			);

endmodule
