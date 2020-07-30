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



module TB_MIPS();
    
	reg clk;
	reg reset;
	reg [31:0] i_data_address;
    reg i_W_E;
	reg [31:0] i_instruc_address;
	reg i_debug;
    integer fd_program;
    
    MIPS # (
    	.LEN(32)
 	)
    MIPS(
        .clk(clk),
        .reset(reset),
        .i_data_address(i_data_address),
        .i_W_E (i_W_E),
        .i_instruc_address (i_instruc_address),
        .i_debug (i_debug)
    );

	initial
	begin
		clk = 0;
		reset = 1;
		i_debug = 0;
		#10
		reset = 0;
		i_instruc_address = 32'b0;
		i_W_E = 1;
		fd_program=$fopen("D:/ARQUITECTURA/TPFinal_Arqui2020/program.txt","r");   //"r" means reading and "w" means writing
        //read line by line.
        while (! $feof(fd_program)) begin //read until an "end of file" is reached.
            $fscanf(fd_program,"%b\n",i_data_address); //scan each line and get the value as an hexadecimal, use %b for binary and %d for decimal.
            #10; //wait some time as needed.
            i_instruc_address = i_instruc_address + 1;
        end 
    //once reading and writing is finished, close the file.
        $fclose(fd_program);
		i_W_E = 0;
        //step by step
       /* #10
        i_debug = 1;
        #40
        i_debug  =0;
        #10
        i_debug = 1;
        #40
        i_debug  =0;
        #10
        i_debug = 1;
        #40
        i_debug  =0;
        #10
        i_debug = 1;
        #40
        i_debug  =0;
        */
	end

	always 
	begin
		#5 clk = ~clk;
	end
    
endmodule
