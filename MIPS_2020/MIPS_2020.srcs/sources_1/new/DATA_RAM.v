`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.06.2020 17:15:09
// Design Name: 
// Module Name: DATA_RAM
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



module DATA_RAM #(
  parameter RAM_WIDTH = 16,                       // Specify RAM data width
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "LOW_LATENCY", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] i_addressD,  // Address bus, width determined from RAM_DEPTH
  input [RAM_WIDTH-1:0] i_dataD,           // RAM input data
  input clka,                           // Clock
  //input ctrl_clk_mips,
  input i_writeEnable,                            // Write enable
  input enable,                            // RAM Enable, for additional power savings, disable port when not in use
  output [RAM_WIDTH-1:0] o_dataD,         // RAM output data
  output [RAM_WIDTH-1:0] o_wire_dataD     // RAM output data wire
);
  wire regcea = 1;                         // Output register enable
  wire rsta = 0; // Output reset (does not affect memory contents)

  reg [RAM_WIDTH-1:0] BRAM [RAM_DEPTH-1:0];
  reg [RAM_WIDTH-1:0] ram_data = {RAM_WIDTH{1'b0}};


  assign o_wire_dataD = BRAM[i_addressD];

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      integer valor = 0;//128;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {RAM_WIDTH{1'b0}}+(ram_index)+valor;
    end
  endgenerate

  always @(negedge clka)
  begin
    //if (ctrl_clk_mips) begin
    
		if (i_writeEnable)
			BRAM[i_addressD] <= i_dataD;
		if (enable)
			ram_data <= BRAM[i_addressD];
    //end
  end

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign o_dataD = ram_data;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] douta_reg = {RAM_WIDTH{1'b0}};

      always @(negedge clka)
        if (rsta)
          douta_reg <= {RAM_WIDTH{1'b0}};
        else if (regcea)
          douta_reg <= ram_data;

      assign o_dataD = douta_reg;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2; //cuantos bist necesito para direccionar clogb2 (1024 para datos) posiciones
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule
