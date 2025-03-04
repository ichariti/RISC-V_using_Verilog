`timescale 1ns / 1ps
module regfile(
  output reg [DATAWIDTH-1:0] readData1,
  output reg [DATAWIDTH-1:0] readData2,
  input clk,
  input [4:0] readReg1,
  input [4:0] readReg2,
  input [4:0] writeReg,
  input [DATAWIDTH-1:0] writeData,
  input write);
  
  parameter DATAWIDTH = 32;
  reg [DATAWIDTH-1 :0] register [31:0];
  
  initial begin: initialize_registers	//it is required to name the block when declaring local variables
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
      register[i] = 0;
    end
  end
  
  // Write
  always @(posedge clk) begin
	    if (write) begin
    	  register[writeReg] <= writeData;  
    	end
  end
  
  // Read 
   always @(posedge clk) begin
        // Prioritize write over read if readReg1 is the same as writeReg
        if (write && (writeReg == readReg1)) begin
            readData1 <= writeData;  // If we are writing to the same register as readReg1, return the written data
        end else begin
            readData1 <= register[readReg1];  // Else, just read the register
        end
        // Prioritize write over read if readReg2 is the same as writeReg
        if (write && (writeReg == readReg2)) begin
            readData2 <= writeData;  // If we are writing to the same register as readReg2, return the written data
        end else begin
            readData2 <= register[readReg2];  // Else, just read the register
        end
    end 
endmodule

