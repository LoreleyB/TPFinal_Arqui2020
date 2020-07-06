`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2020 17:26:09
// Design Name: 
// Module Name: IMEMORY
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



module IMEMORY #(
	parameter len = 32,
	parameter NB = $clog2(len),
	parameter len_mem_bus = 9,
	parameter len_wb_bus = 2
	)(
	input clk,
	
	input reset,
	input [len-1:0] i_addressMem,
	input [len-1:0] i_writeData,
	input [len_mem_bus-1:0] i_signalControlME,
    input [len_wb_bus-1:0] i_signalControlWB,
	input [NB-1:0] i_writeReg,	

	input i_zeroFlag,
	input [len-1:0] i_pcBranch,
	input i_haltFlag_MEM,

	output reg [len-1:0] o_readData,
	output o_flagBranch,
	output [len-1:0] o_pcBranch,
    output reg [1:0] o_signalControlWB,
	output reg [len-1:0] o_addressMem,
	output reg [NB-1:0] o_writeReg,
	output reg o_haltFlag_MEM
    );

	wire 	w_memWrite,
			w_memRead,
			w_branch,
			w_controlUnsigned,
			w_control_LH,
			w_control_LB,
			w_control_SH,
			w_control_SB,
			w_branchNotEqual;

	reg [len-1:0] 	r_dataIn;
	wire [len-1:0]	w_dataOut;





	assign w_memWrite			= i_signalControlME[0],
		   w_memRead 			= i_signalControlME[1],
		   w_branch   		= i_signalControlME[2],
		   w_controlUnsigned = i_signalControlME[3],
		   w_control_LH 		= i_signalControlME[4],
		   w_control_LB 		= i_signalControlME[5],
		   w_control_SH 		= i_signalControlME[6],
		   w_control_SB 		= i_signalControlME[7],
		   w_branchNotEqual   = i_signalControlME[8];

	assign o_pcBranch = i_pcBranch;
	assign o_flagBranch = w_branch && ((w_branchNotEqual) ? (~i_zeroFlag) : (i_zeroFlag));	
	// la señal de Branch se activa con ambas intrucciones de branch, la otra señal te indica cual de las 2 fue
    // o_flagBranch es el bit menos significativo de i_pcSrc[2:0] de FETH


	DATA_RAM #(
		.RAM_WIDTH(32),
		.RAM_DEPTH(2048)
		)
		DATA_RAM(
			.i_addressD(i_addressMem),
			.i_dataD(r_dataIn),
			.clka(clk),
			
			.i_writeEnable(w_memWrite),
			.enable(w_memRead),
			.o_dataD(w_dataOut)
			);

	always @(posedge clk, posedge reset) 
	begin

		if(reset)
		begin
			o_readData <= 0;
		    o_signalControlWB <= 0;
			o_addressMem <= 0;
			o_writeReg <= 0;
			o_haltFlag_MEM <= 0;
		end

		
		else begin
			o_haltFlag_MEM <= i_haltFlag_MEM;

			o_signalControlWB <= i_signalControlWB;
			o_addressMem <= i_addressMem;
			o_writeReg <= i_writeReg;

			if (w_control_LH) //Load Half Word
			begin
				if (w_controlUnsigned) 
				begin
					o_readData <= {{16{1'b 0}},w_dataOut[15:0]};
				end
				else 
				begin
					o_readData <= {{16{w_dataOut[15]}},w_dataOut[15:0]};				
				end
			end
			else if (w_control_LB) //Load Byte
			begin
				if (w_controlUnsigned) 
				begin
					o_readData <= {{24{1'b 0}},w_dataOut[7:0]};//0x24, w_dataOut[7:0]
				end
				else 
				begin
					o_readData <= {{24{w_dataOut[7]}},w_dataOut[7:0]};	//1x24, w_dataOut[7:0]			
				end
			end
			else 
			begin
				o_readData <= w_dataOut;//LW				
			end
		end
	end

	always @(*)
	begin

		if (w_control_SH) // Store Half Word
		begin
			r_dataIn <= {{16{i_writeData[15]}},i_writeData[15:0]};
		end
		else if (w_control_SB) //Store Byte
		begin
			r_dataIn <= {{24{i_writeData[7]}},i_writeData[7:0]};				
		end
		else 
		begin
			r_dataIn <= i_writeData; //SW			
		end


	end

endmodule

