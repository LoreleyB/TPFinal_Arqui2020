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
    reg [31:0] dato;
    reg wea;
	reg [31:0] dire;
    integer outfile0; //file descriptor
    
    MIPS#(
    	.LEN(32)
    	//.INIT_FILE("C:/Ensamblador/instructions.bin") //C:/Facultad/TPFinal_Arqui2020/MIPS_2020/program.hex
    	//.INIT_FILE("") //C:/Facultad/TPFinal_Arqui2020/MIPS_2020/program.hex
 		)
        MIPS(
        	.clk(clk),
        	.reset(reset),
       	    .i_dina(dato),
       	    .i_writeEnable(wea),
       	    .i_addressI(dire)
        );

	initial
	begin
		clk = 0;
		reset = 1;
		#10
		reset = 0;
        
        
        dire = 32'b0;  
        wea = 1;  
        outfile0=$fopen("C:/Ensamblador/instructions.bin","r");   //"r" means reading and "w" means writing
        //read line by line.
        while (! $feof(outfile0)) begin //read until an "end of file" is reached.
            $fscanf(outfile0,"%b\n",dato); //scan each line and get the value as an hexadecimal, use %b for binary and %d for decimal.
            #10; //wait some time as needed.
            dire = dire + 1;
        end 
    //once reading and writing is finished, close the file.
        $fclose(outfile0);
		
		wea = 0;
		
		
		
		//dato = 32'b00000000101001000000100000100001;
		//dire = 32'b0;
		
		

		//#10
		//wea = 0;
	end

	always 
	begin
		#5 clk = ~clk;
	end
    
endmodule
