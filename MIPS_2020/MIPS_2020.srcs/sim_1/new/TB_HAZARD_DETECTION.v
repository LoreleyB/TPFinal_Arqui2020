`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2020 10:27:50
// Design Name: 
// Module Name: TB_HAZARD_DETECTION
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



`define len 32
`define NB $clog2(`len)

module TB_HAZARD_DETECTION(
    );
	
	reg i_memRead_IDEX;
	reg [`NB-1:0] i_rt_IDEX;
	reg [`NB-1:0] i_rs_IFID;
	reg [`NB-1:0] i_rt_IFID;
	reg CLK100MHZ;

	HAZARD_DETECTION #(.len(`len), .NB(`NB))
	HAZARD_DETECTION(
		.i_memRead_IDEX(i_memRead_IDEX), //que la inst anterior sea un load
		.i_rt_IDEX(i_rt_IDEX), //destino del load
		.i_rs_IFID(i_rs_IFID), //source de la inst actual
		.i_rt_IFID(i_rt_IFID) //source de la inst atual
		);

	initial begin
		CLK100MHZ = 0;

		i_memRead_IDEX = 0;
		i_rt_IDEX = 1;
		i_rs_IFID = 0;
		i_rt_IFID = 0;
		//stallFlag = 0, no hay riesgo
		#10

		i_memRead_IDEX = 0;
		i_rt_IDEX = 1;
		i_rs_IFID = 1;
		i_rt_IFID = 0;
		//stallFlag = 0, no hay riesgo
		#10

		i_memRead_IDEX = 0;
		i_rt_IDEX = 1;
		i_rs_IFID = 0;
		i_rt_IFID = 1;
		//stallFlag = 0, no hay riesgo
		#10

		i_memRead_IDEX = 0;
		i_rt_IDEX = 1;
		i_rs_IFID = 1;
		i_rt_IFID = 1;
		//stallFlag = 0, no hay riesgo
		#10

		i_memRead_IDEX = 1;
		i_rt_IDEX = 1;
		i_rs_IFID = 0;
		i_rt_IFID = 0;
		//stallFlag = 0, no hay riesgo porque isnt actual no usa como operandos resultado del load
		#10

		i_memRead_IDEX = 1;
		i_rt_IDEX = 1;
		i_rs_IFID = 0;
		i_rt_IFID = 1;
		//stallFlag = 1, hay riesgo
		#10

		i_memRead_IDEX = 1;
		i_rt_IDEX = 1;
		i_rs_IFID = 1;
		i_rt_IFID = 0;
		//stallFlag = 1, hay riesgo
		#10

		i_memRead_IDEX = 1;
		i_rt_IDEX = 1;
		i_rs_IFID = 1;
		i_rt_IFID = 1;
        //stallFlag = 1, hay riesgo
	
        #10
        i_memRead_IDEX = 0;
		i_rt_IDEX = 1;
		i_rs_IFID = 0;
		i_rt_IFID = 1;
		//stallFlag = 0, no hay riesgo
		
	
	end

	always
		#5 CLK100MHZ = ~CLK100MHZ;
		
endmodule