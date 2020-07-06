`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.06.2020 19:59:56
// Design Name: 
// Module Name: INSTRUCTION_RAM
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


module INSTRUCTION_RAM #(
  parameter RAM_WIDTH = 32,                       // Ancho de la palabra
  parameter RAM_DEPTH = 2048,                     // Profundidad (numero de entradas)
  parameter INIT_FILE = ""                        // ruta program
) (
  input [RAM_WIDTH-1:0] i_addressI,            
  input clka,                             
  input enable,                              
  input i_flush,
  input reset,
  output [RAM_WIDTH-1:0] o_dataI,           
  output o_validI       // ultima instruccion FFFF
);


  reg [RAM_WIDTH-1:0] r_matrixIRAM [RAM_DEPTH-1:0]; 
  reg [RAM_WIDTH-1:0] r_instructionRAM = {RAM_WIDTH{1'b0}};

  assign o_validI = &r_matrixIRAM[i_addressI][RAM_WIDTH-1:RAM_WIDTH-6];  
   // verifica si el opcode es 111111, si lo hace haltflag (final de instrucciones FFFF) . Hace & (AND) bit a bit de los bits 31 al 26 de la PC 
   

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        //$readmemh(INIT_FILE, r_matrixIRAM, 0, RAM_DEPTH-1);
        $readmemb(INIT_FILE, r_matrixIRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          r_matrixIRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge clka, posedge reset)
  begin
		if(reset) begin
			r_instructionRAM <= 0;
		end
		
		else if (enable)	begin
				if(i_flush)
				    r_instructionRAM <= 0; //NOP
                else
                    r_instructionRAM <= r_matrixIRAM[i_addressI];
			end
  end

  assign o_dataI = r_instructionRAM;

endmodule
