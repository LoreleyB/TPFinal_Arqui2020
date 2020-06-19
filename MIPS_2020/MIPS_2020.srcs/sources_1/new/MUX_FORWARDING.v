`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.06.2020 20:10:30
// Design Name: 
// Module Name: MUX_FORWARDING
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


module MUX_FORWARDING #(
	parameter len = 32
	) (
	input [len-1:0] i_dataReg,			//entrada desde registros
	input [len-1:0] i_dataMEM,	//salida de alu de clock anterior
	input [len-1:0] i_dataWB,		//salida del mux final de writeback
	input [1:0] select,
	output [len-1:0] o_dataMux
    );

    assign o_dataMux 	= (select == 2'b00) ? i_dataReg
    				: (select == 2'b01) ? i_dataMEM
    									: i_dataWB;    
endmodule
