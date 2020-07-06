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
	parameter len_wb_bus = 2
	)(
	input clk,
	input reset,


	output [LEN-1:0] o_PC,
	output o_haltFlag //instruccion final FFFF

	);

    wire [LEN-1:0] w_pcBranch_IFID,
				   w_pcBranch_IDEX,
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
				   w_pcBranch_MEMIF, 
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
	     w_zeroFlag,
	     w_flagBranch,
	     w_hazardFlag, //bandera de control de riesgo, caso del load
	     w_haltFlag_IFID,
	     w_haltFlag_IDEX,
	     w_haltFlag_EXMEM,
	     w_haltFlag_MEMWB; 

	assign w_writeData_WBID = (w_signalControlWB_bus[0]) ? w_readData : w_addressMem_aluResult;
	//si MemtoReg=1 toma dato de memoria, sino toma resultado de Alu, ultimo mux

	assign o_PC = w_PC;
	assign o_haltFlag = w_haltFlag_MEMWB;


	IFETCH #(
		.len(LEN)
		)
		IFETCH(
			.clk(clk),
			
			.reset(reset),
			.i_pcSrc({w_flagJump, w_flagJumpRegister, w_flagBranch}), 
			.i_pcJump(w_pcJump),
			.i_pcBranch(w_pcBranch_MEMIF),
			.i_pcRegister(w_pcJumpRegister),
			.i_stallFlag(!w_hazardFlag),// Hazzard Detection, enable del modulo PC


			.o_pcBranch(w_pcBranch_IFID),
			.o_instruction(w_instruccion),
			.o_PC(w_PC), 
			.o_haltFlag_IF(w_haltFlag_IFID)
		);

	IDECODE #(
		.len(LEN)
		)
		IDECODE(
			.clk(clk),
			
			.reset(reset),
			.i_pcBranch(w_pcBranch_IFID),
			.i_instruction(w_instruccion),
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

			
            .o_haltFlag_ID(w_haltFlag_IDEX),
            

			.o_flagJump(w_flagJump),
			.o_flagJumpRegister(w_flagJumpRegister),
			.o_signalControlEX(w_signalControlEX),
            .o_signalControlME(w_signalControlME_IDEX),
			.o_signalControlWB(w_signalControlWB_IDEX),

			.o_hazardFlag(w_hazardFlag)

			
			
		);

	IEXECUTE #(
		.len(LEN)
		)
		IEXECUTE(
			.clk(clk),
			
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

            //FW
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
			.o_zeroFlag(w_zeroFlag),
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
			
			.reset(reset),
			.i_addressMem(w_aluResult),
			.i_writeData(w_writeData_EXMEM),
			
			.i_signalControlME(w_signalControlME_EXMEM),
		    .i_signalControlWB(w_signalControlWB_EXMEM),
			.i_writeReg(w_writeReg_EXMEM),			
			.i_zeroFlag(w_zeroFlag),
			.i_pcBranch(w_pcBranch_EXMEM),

			.i_haltFlag_MEM(w_haltFlag_EXMEM),
			
			//outputs		
			.o_readData(w_readData),
			.o_flagBranch(w_flagBranch), //confirma BEQ y BNEQ
			.o_pcBranch(w_pcBranch_MEMIF),
		    .o_signalControlWB(w_signalControlWB_bus),
			.o_addressMem(w_addressMem_aluResult),
			//se usa como entrada al MUX de la etapa WB, es el resultado de la ALU. Ver de hacer la etapa WB
			.o_writeReg(w_writeReg_MEMID),
			.o_haltFlag_MEM(w_haltFlag_MEMWB)
			);



endmodule
