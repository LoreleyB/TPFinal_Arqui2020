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
    reg [31:0] r_dina;
    reg r_writeEnable;
	reg [31:0] r_addressI;
	reg i_stepByStep;
    integer fd_outFile; //file descriptor
    
    MIPS#(
    	.LEN(32)
    	//.INIT_FILE("C:/Ensamblador/instructions.bin") //C:/Facultad/TPFinal_Arqui2020/MIPS_2020/program.hex
    	//.INIT_FILE("") //C:/Facultad/TPFinal_Arqui2020/MIPS_2020/program.hex
 		)
        MIPS(
        	.clk(clk),
        	.reset(reset),
       	    .i_dina(r_dina),
       	    .i_writeEnable(r_writeEnable),
       	    .i_addressI(r_addressI),
       	    .i_stepByStep(i_stepByStep)
        );

	initial
	begin
		clk = 0;
		reset = 1;
		i_stepByStep = 0;
		#10
		reset = 0;
        
        r_addressI = 32'b0;  
        r_writeEnable = 1;  
        fd_outFile=$fopen("C:/Ensamblador/instructions.bin","r");   //"r" means reading and "w" means writing
        //read line by line.
        while (! $feof(fd_outFile)) begin //read until an "end of file" is reached.
            $fscanf(fd_outFile,"%b\n",r_dina); //scan each line and get the value as an hexadecimal, use %b for binary and %d for decimal.
            #10; //wait some time as needed.
            r_addressI = r_addressI + 1;
        end 
    //once reading and writing is finished, close the file.
        $fclose(fd_outFile);
		r_writeEnable = 0;
	
    
        //step by step
//        #10
//        i_stepByStep=1;
//        #10
//        i_stepByStep=0;
//        #10
//        i_stepByStep=1;
    
    end
    
    
	always 
	begin
		#5 clk = ~clk;
	end
    
endmodule
