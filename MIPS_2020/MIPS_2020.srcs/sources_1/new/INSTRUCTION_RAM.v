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
  parameter RAM_WIDTH = 32,                       // Specify RAM data width
  parameter RAM_DEPTH = 2048,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not
) (
  input [RAM_WIDTH-1:0] i_addressI,            // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] i_dataI,           // RAM input data
  input clka,                             // Clock
	//input ctrl_clk_mips,
  input enable,                              // RAM Enable, for additional power savings, disable port when not in use
  input i_flush,
  input reset,
  input i_writeEnable,                              // Write enable
  output [RAM_WIDTH-1:0] o_dataI,           // RAM output data
  output o_validI       // WIRE RAM output data, instruccion  valida
);
  wire rsta = 0;                           // Output reset (does not affect memory contents)
  wire regcea = 1;                         // Output register enable

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};

  assign o_validI = &BRAM[i_addressI][RAM_WIDTH-1:RAM_WIDTH-6];  
   // verifica si el opcode es 111111, si lo hace stallFlag. Hace & (AND) bit a bit de los bits 31 al 26 de la PC 
   

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        //$readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
        $readmemb(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}};
    end
  endgenerate

  always @(posedge i_writeEnable) begin
	BRAM[i_addressI] <= i_dataI;  //escribe en memoria de instrucciones desde la uart
  end

  always @(posedge clka, posedge reset)
  begin
		if(reset) begin
			ram_data <= 0;
		end
		//else if (ctrl_clk_mips) begin
		else if (enable)	begin
				if(i_flush)
				ram_data <= 0; //NOP
				else
				ram_data <= BRAM[i_addressI];
			end
		//end
  end

  // assign o_dataI = BRAM[addra >> 2];

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_dataI = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clka)
        if (rsta)
          douta_reg <= {RAM_WIDTH{1'b0}};
        else if (regcea)
          douta_reg <= ram_data;

      assign o_dataI = douta_reg;

    end
  endgenerate

endmodule
