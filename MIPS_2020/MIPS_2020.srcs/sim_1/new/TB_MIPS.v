`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2020 20:47:21
// Design Name: 
// Module Name: TB_MIPS
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



module TB_MIPS(

    );
    
	reg clk;
	reg reset;
    
	

    MIPS#(
    	.LEN(32),
    	.INIT_FILE("C:/Ensamblador/instructions.bin") //C:/Facultad/TPFinal_Arqui2020/MIPS_2020/program.hex
 		)
        MIPS(
        	.clk(clk),
        	.reset(reset)
       	
        );

	initial
	begin
		clk = 0;
		reset = 1;
		#10
		reset = 0;
	end

	always 
	begin
		#5 clk = ~clk;
	end
    
endmodule
