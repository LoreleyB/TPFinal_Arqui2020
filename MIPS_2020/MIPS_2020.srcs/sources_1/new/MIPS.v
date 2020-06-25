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
				   w_writeData_WBID,  //y además entra a los MUXA y MUXB determinados por FW de EX
				   w_readData,
				   w_addressMem_aluResult,
				   w_writeData_EXMEM, 
				   w_pcBranch_EXMEM,
				   w_pcBranch_MEMIF, //No deberia salir de DECODE????? esta saliendo de MEM y va a IF
				   w_registerARecolector,
				   w_wireMem,
				   w_PC;

	wire [NB-1:0] w_rt,
				  w_rd,
				  w_rs,
				  w_shamt,
				  w_writeReg_EXMEM, //y  además entra al FW de EX
				  w_writeReg_MEMID;// y además entra al FW de EX

    wire [len_exec_bus-1:0] w_signalControlEX;//señales de control de EX
	
	wire [len_mem_bus-1:0] w_signalControlME_IDEX, //señales de control de ME que cablean ID con EX
			   w_signalControlME_EXMEM; //señales de control de ME qur cablean EX con ME
	
	wire [len_wb_bus-1:0] w_signalControlWB_IDEX, //señales de control de WB que cablean de ID a EX
			   w_signalControlWB_bus, //Señales de control de WB que cablean señal  MEM con ID (WriteReg) y MEM con EX (WriteReg) 
			   w_signalControlWB_EXMEM; //señales de control de WB que cablean de EX a MEM, vuleve a EX la señal WriteReg par FW 
    
    wire w_flagJump,
         w_flagJumpRegister,
	     connect_zero_flag,
	     w_flagBranch,
	     w_flagStall, //bandera de control de riesgo, caso del load
	     w_haltFlag_IFID,
	     w_haltFlag_IDEX,
	     w_haltFlag_EXMEM,
	     w_haltFlag_MEMWB; 

	assign w_writeData_WBID = (w_signalControlWB_bus[0]) ? w_readData : w_addressMem_aluResult;//si MemtoReg=1 entoces toma dato de memoria, sino toma resultado de Alu, ultimo mux

	assign o_registerARecolector = w_registerARecolector;
	assign o_wireMem = w_wireMem;
	assign o_PC = w_PC;
	assign o_haltFlag = w_haltFlag_MEMWB;

	assign o_latches_IFID = {	// 2 registros
		w_instruccion, // 32 bits
		w_pcBranch_IFID // 32 bits
	};
	assign o_latches_IDEX = {	// 4 registros
		{10{1'b 0}}, // 10 bits
		w_signalControlEX, // 11 bits
		w_signalControlME_IDEX, // 9 bits
		w_signalControlWB_IDEX, // 2 bits
		{12{1'b 0}}, // 12 bits
		w_rd, // 5 bits
		w_rs, // 5 bits
		w_rt, // 5 bits
		w_shamt, // 5 bits
		w_signExtend, // 32 bits
		w_pcBranch_IDEX // 32 bits
	};
	assign o_latches_EXMEM = {	// 4 registros
		{15{1'b 0}}, // 15 bits
		w_signalControlME_EXMEM, // 9 bits
		w_signalControlWB_EXMEM, // 2 bits
		w_writeReg_EXMEM, // 5 bits
		connect_zero_flag, // 1 bit
		w_aluResult, // 32 bits
		w_pcBranch_EXMEM, // 32 bits
		w_registerDataB // 32 bits
	};
	assign o_latches_MEMWB = {	// 3 registros
		{24{1'b 0}}, // 24 bits
		w_haltFlag_MEMWB, // 1 bit
		w_writeReg_MEMID, // 5 bits
		w_signalControlWB_bus, // 2 bits
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
			.i_pcSrc({w_flagJump, w_flagJumpRegister, w_flagBranch}),
			.i_pcJump(w_pcJump),
			.i_pcBranch(w_pcBranch_MEMIF),
			.i_pcRegister(w_pcJumpRegister),
			.i_stallFlag(!w_flagStall),

			.i_addressDebug(i_addressMemInst),
			.i_debugFlag(i_debugFlag),
			.i_instructoMemo(i_instructoMemo),
			.i_writeEnable_inst(i_writeEnable_inst),

			.o_pcBranch(w_pcBranch_IFID),
			.o_instruction(w_instruccion),
			.o_PC(w_PC), // para debug
			.o_haltFlag_IF(w_haltFlag_IFID) // para debug
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
			.i_flagRegWrite(w_signalControlWB_bus[1]),
			.i_writeData(w_writeData_WBID),
			.i_writeRegister(w_writeReg_MEMID),
			.i_flush(w_flagBranch),
			.i_haltFlag_ID(w_haltFlag_IFID),
			
			.o_pcBranch(w_pcBranch_IDEX),
			.o_pcJump(w_pcJump),
			.o_pcJumpRegister(w_pcJumpRegister),
			.o_registerDataA(w_registerDataA),
			.o_registerDataB(w_registerDataB),
			.o_signExtend(w_signExtend),
			.o_rt(w_rt),
			.o_rd(w_rd),
			.o_rs(w_rs),
			.o_shamt(w_shamt),

			.o_registerARecolector(w_registerARecolector),
            .o_haltFlag_ID(w_haltFlag_IDEX),
            

			.o_flagJump(w_flagJump),
			.o_flagJumpRegister(w_flagJumpRegister),
			.o_signalControlEX(w_signalControlEX),
            .o_signalControlME(w_signalControlME_IDEX),
			.o_signalControlWB(w_signalControlWB_IDEX),

			.o_stallFlag(w_flagStall)

			
			
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
			.i_rt(w_rt),
			.i_rd(w_rd),
			.i_shamt(w_shamt),
		
			.i_signalControlEX(w_signalControlEX),
			.i_signalControlME(w_signalControlME_IDEX),
			.i_signalControlWB(w_signalControlWB_IDEX), 

			.i_registerWrite_EXMEM(w_signalControlWB_EXMEM[1]),// señal RegWrite
			.i_registerWrite_MEMWB(w_signalControlWB_bus[1]),// señal RegWrite
			.i_rd_EXMEM(w_writeReg_EXMEM),
			.i_rd_MEMWB(w_writeReg_MEMID),
			.i_rs(w_rs),

			.i_dataMEM_FW(w_aluResult),
			.i_dataWB_FW(w_writeData_WBID),
			.i_flush(w_flagBranch),
		
		    .i_haltFlag_EX(w_haltFlag_IDEX),
			
			.o_pcBranch(w_pcBranch_EXMEM),
			.o_alu(w_aluResult),
			.o_zeroFlag(connect_zero_flag),
			.o_dataRegB(w_writeData_EXMEM),
			.o_writeReg(w_writeReg_EXMEM),
		
			.o_haltFlag_EX(w_haltFlag_EXMEM),
			
			// seÃ±ales de control
			.o_signalControlME(w_signalControlME_EXMEM),
			.o_signalControlWB(w_signalControlWB_EXMEM)
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
			
			.i_signalControlME(w_signalControlME_EXMEM),
		    .i_signalControlWB(w_signalControlWB_EXMEM),
			.i_writeReg(w_writeReg_EXMEM),			
			.i_zeroFlag(connect_zero_flag),
			.i_pcBranch(w_pcBranch_EXMEM),

			.i_haltFlag_MEM(w_haltFlag_EXMEM),
			
			//outputs		
			.o_readData(w_readData),
			.o_pcSrc(w_flagBranch),
			.o_pcBranch(w_pcBranch_MEMIF),
		    .o_signalControlWB(w_signalControlWB_bus),
			.o_addressMem(w_addressMem_aluResult),//se usa como entrada al MUX de la etapa WB, es el resultado de la ALU. Ver de hacer la etapa WB
			.o_writeReg(w_writeReg_MEMID),

			.o_wireMem(w_wireMem), // para debug
			
			.o_haltFlag_MEM(w_haltFlag_MEMWB)
			);

endmodule
