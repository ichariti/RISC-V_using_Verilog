// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps
`include "ram.v"
`include "rom.v"

module top_proc_tb;
  wire [31:0] PC;
  wire [31:0] dAddress;
  wire [31:0] dWriteData;
  wire MemRead;
  wire MemWrite;
  wire [31:0] WriteBackData;
  reg clk;
  reg rst;
  reg [31:0] instr;
  reg [31:0] dReadData;
  
  top_proc TOP_PROC_TB(PC, dAddress, dWriteData, MemRead, MemWrite, WriteBackData, clk, rst, instr, dReadData);
  DATA_MEMORY DM(clk, MemWrite, dAddress, dWriteData, dReadData);
  INSTRUCTION_MEMORY IM(clk, PC, instr);
  
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,top_proc_tb);
    clk=1'b0;
    rst=1'b0;
    #10 rst=1'b1;
  end
  
  initial #3000 $finish;
  always #10 clk=~clk;
  
endmodule