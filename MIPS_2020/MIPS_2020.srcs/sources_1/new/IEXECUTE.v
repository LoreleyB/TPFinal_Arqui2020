`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2020 20:23:43
// Design Name: 
// Module Name: IEXECUTE
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



module IEXECUTE #(
	parameter len = 32,
	parameter NB =  $clog2(len),
	parameter len_exec_bus = 11,
	parameter len_mem_bus = 9,
	parameter len_wb_bus = 2
	)(
	input clk,
	//input ctrl_clk_mips,
	input reset,

	input [len-1:0] i_pcBranch,
	input [len-1:0] i_dataRegA,
	input [len-1:0] i_dataRegB,
	input [len-1:0] i_signExtend,
	input [NB-1:0] i_rt,
	input [NB-1:0] i_rd,
	input [NB-1:0] i_shamt,

	input [len_exec_bus-1:0] i_signalControlEX,
	input [len_mem_bus-1:0] i_signalControlME,
	input [len_wb_bus-1:0] i_signalControlWB,

	// entradas para cortocircuito
	input i_registerWrite_EXMEM,	// flag
	input i_registerWrite_MEMWB,	// flag
	input [NB-1:0] i_rd_EXMEM,		// registro ya calculado, a forwardear
	input [NB-1:0] i_rd_MEMWB,		// registro ya calculado, a forwardear
	input [NB-1:0] i_rs,		// registro de instr siguiente que puede necesitar forwarding

	input [len-1:0] i_dataMEM_FW,
	input [len-1:0] i_dataWB_FW,
	input i_flush,
	input i_haltFlag_EX,
	
	output reg [len-1:0] o_pcBranch,
	output reg [len-1:0] o_alu,
	output reg o_zeroFlag,
	output reg [len-1:0] o_dataRegB,
	output reg [NB-1:0] o_writeReg,

	output reg o_haltFlag_EX,

	// señales de control
	output reg [len_mem_bus-1:0] o_signalControlME,
	output reg [len_wb_bus-1:0] o_signalControlWB
    );

	wire [1:0] 	w_muxA_FW,
				w_muxB_FW;
				
    wire [len-1:0] 	w_muxA_alu_FW,
    				w_muxB_alu_FW;

	wire [len-1:0] w_aluOpA = i_signalControlEX[10] ? (i_pcBranch) : (i_signalControlEX[7] ? ({{27{1'b 0}}, i_shamt}) : w_muxA_alu_FW);
	wire [len-1:0] w_aluOpB = i_signalControlEX[10] ? (1'b 1) : (i_signalControlEX[6] ? i_signExtend : w_muxB_alu_FW);
	wire [len-1:0] w_aluOut;
	wire w_zeroFlag;


	ALU #(
		.lenghtIN(32),
		.lenghtOP(4)
		)
		ALU(
			.i_dataA(w_aluOpA),
			.i_dataB(w_aluOpB),
			.i_opCode(i_signalControlEX[3:0]),
	
			.o_result(w_aluOut),
			.o_zeroFlag(w_zeroFlag)
		);

	FORWARDING_UNIT #(
		.len(len)
		)
		FORWARDING_UNIT(
			.i_registerWrite_EXMEM(i_registerWrite_EXMEM),	// flag
			.i_registerWrite_MEMWB(i_registerWrite_MEMWB),	// flag
			.i_rd_EXMEM(i_rd_EXMEM),		// registro ya calculado, a forwardear
			.i_rd_MEMWB(i_rd_MEMWB),		// registro ya calculado, a forwardear
			.i_rs_IDEX(i_rs),		// registro de instr siguiente que puede necesitar forwarding
			.i_rt_IDEX(i_rt),		// registro de instr siguiente que puede necesitar forwarding

			.o_controlFWMuxA(w_muxA_FW),
			.o_controlFWMuxB(w_muxB_FW)
		);

	MUX_FORWARDING #(.len(32))
		MUX_FORWARDING_A(
			.i_dataReg(i_dataRegA),			//entrada desde registros
			.i_dataMEM(i_dataMEM_FW),	//salida de alu de clock anterior
			.i_dataWB(i_dataWB_FW),	//salida del mux final de writeback
			.select(w_muxA_FW),
			.o_dataMux(w_muxA_alu_FW)
			);
	
	MUX_FORWARDING #(.len(32))
		MUX_FORWARDING_B(
			.i_dataReg(i_dataRegB),			//entrada desde registros
			.i_dataMEM(i_dataMEM_FW),	//salida de alu de clock anterior
			.i_dataWB(i_dataWB_FW),	//salida del mux final de writeback
			.select(w_muxB_FW),
			.o_dataMux(w_muxB_alu_FW)
			);

	always @(posedge clk, posedge reset) 
	begin
		if (reset) begin
			o_pcBranch <= 0;
			o_alu <= 0;
			o_zeroFlag <= 0;
			o_dataRegB <= 0;
			o_writeReg <= 0;
			o_signalControlME <= 0;
			o_signalControlWB <= 0;
			o_haltFlag_EX <= 0;			
		end

		//else if (ctrl_clk_mips) begin
		else begin
			o_haltFlag_EX <= i_haltFlag_EX;

			if (i_flush) 
			begin
				o_signalControlME <= 0;
				o_signalControlWB <= 0;
				o_pcBranch <= 0;
				o_alu <= 0;
				o_dataRegB <= 0;
				o_writeReg <= 0;
				o_zeroFlag <= 0;
			end
			else
			begin		
				o_signalControlME <= i_signalControlME;
				o_signalControlWB <= i_signalControlWB;
				o_pcBranch <= i_pcBranch + i_signExtend;
				o_alu <= w_aluOut;
				o_dataRegB <= i_dataRegB;
				o_writeReg <= i_signalControlEX[9] ? (5'b 11111) : (i_signalControlEX[8] ? i_rd : i_rt);
				o_zeroFlag <= w_zeroFlag;
			end
		end
	end

endmodule
