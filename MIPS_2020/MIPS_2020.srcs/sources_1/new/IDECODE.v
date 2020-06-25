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
	input [len-1:0] i_pcBranch,
	input [len-1:0] i_instruction,
	input i_flagRegWrite,
	input [len-1:0] i_writeData,
	input [NB-1:0] i_writeRegister,
	input i_flush,
	input i_haltFlag_ID,

	output reg [len-1:0] o_pcBranch,
	output [len-1:0] o_pcJump,	
	output [len-1:0] o_pcJumpRegister,	
	output [len-1:0] o_registerDataA,
	output [len-1:0] o_registerDataB,
	output reg [len-1:0] o_signExtend,
	output reg [NB-1:0] o_rt,
	output reg [NB-1:0] o_rd,
	output reg [NB-1:0] o_rs,
	output reg [NB-1:0] o_shamt,

	output [len-1:0] o_registerARecolector,	// para recolector en modo debug
	output reg o_haltFlag_ID,

	// señales de control
	output o_flagJump,
	output o_flagJumpRegister,
	output reg [len_exec_bus-1:0] o_signalControlEX,
	output reg [len_mem_bus-1:0] o_signalControlME,
	output reg [len_wb_bus-1:0] o_signalControlWB,

	//señal de control de riesgos
	output o_stallFlag
    );

	wire [len_exec_bus-1:0] w_signalControlEX;
	wire [len_mem_bus-1:0] w_signalControlME;
	wire [len_wb_bus-1:0] w_signalControlWB;	

	wire [len-1:0] 	w_outRegisterData1,
					w_registerData1,
					w_registerData2;

    wire w_muxControl; //recibe valor del hazzard detection
    wire [(len_exec_bus+len_wb_bus+len_mem_bus)-1:0] w_outMuxControl = w_muxControl ? 0 : {w_signalControlEX, w_signalControlME, w_signalControlWB};

	assign o_flagJump = (i_flush) ? (0) : (w_signalControlEX[5]);
	assign o_flagJumpRegister = (i_flush) ? (0) : (w_signalControlEX[4]);
	
	assign o_pcJump = (i_flush) ? (0) : ({i_pcBranch[31:28], {2'b 00, (i_instruction[25:0])}});
	assign o_pcJumpRegister = (i_flush) ? (0) : (w_outRegisterData1);

	assign o_registerARecolector = w_outRegisterData1; // para recolector en modo debug
	
    assign o_registerDataA = (i_flush) ? (0) : (w_registerData1); 
    assign o_registerDataB = (i_flush) ? (0) : (w_registerData2);

    assign o_stallFlag = (i_flush) ? (0) : (w_muxControl);

	CONTROL_SIGNALS #()
		CONTROL_SIGNALS(
			.i_opCode(i_instruction[31:26]),
			.i_opCodeFunction(i_instruction[5:0]),
			.o_signalControlEX(w_signalControlEX),
			.o_signalControlME(w_signalControlME),
			.o_signalControlWB(w_signalControlWB)
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
			.i_flagRegWrite(i_flagRegWrite),
			.i_readRegister1(i_instruction[25:21]),
			.i_readRegister2(i_instruction[20:16]),
			.i_writeRegister(i_writeRegister),
			.i_writeData(i_writeData),

			.o_wireReadData1(w_outRegisterData1),
			.o_readData1(w_registerData1),
			.o_readData2(w_registerData2)
			);

	HAZARD_DETECTION #(
		.len(32)
		)
		HAZARD_DETECTION(
			.i_memRead_IDEX(o_signalControlME[1]),
			.i_rt_IDEX(o_rt),
			.i_rs_IFID(i_instruction [25:21]),
			.i_rt_IFID(i_instruction [20:16]),

			.o_stallFlag(w_muxControl)
			);

	always @(posedge clk, posedge reset) 
	begin
		if (reset) begin
			o_pcBranch <= 0;
			o_signExtend <= 0;
			o_rt <= 0;
			o_rd <= 0;
			o_rs <= 0;
			o_shamt <= 0;
			o_signalControlEX <= 0;
			o_signalControlME <= 0;
			o_signalControlWB <= 0;
			o_haltFlag_ID <= 0;
		end

		//else if(ctrl_clk_mips) begin
		else begin
			o_haltFlag_ID <= i_haltFlag_ID;

			if(i_flush)
			begin
				o_pcBranch <= 0;
				o_signExtend <= 0;
				o_rt <= 0;
				o_rd <= 0;
				o_rs <= 0;
				o_shamt <= 0;
				o_signalControlEX <= 0;
				o_signalControlME <= 0;
				o_signalControlWB <= 0;
			end
			else 
			begin			
				o_pcBranch <= i_pcBranch;
				o_signExtend <= $signed(i_instruction[15:0]);   
				 
				o_rt <= i_instruction [20:16];
				o_rd <= i_instruction [15:11];
				o_rs <= i_instruction [25:21];
				o_shamt <= i_instruction [10:6];
				o_signalControlEX <= w_outMuxControl[(len_mem_bus+len_wb_bus+len_exec_bus)-1:len_mem_bus+len_wb_bus];//ultimos 11 bits
				o_signalControlME <= w_outMuxControl[(len_mem_bus+len_wb_bus)-1:len_wb_bus];//desde el 2 al 11 bits
				o_signalControlWB <= w_outMuxControl[len_wb_bus-1:0];//primeros 2		
			end	
		end
	end

endmodule