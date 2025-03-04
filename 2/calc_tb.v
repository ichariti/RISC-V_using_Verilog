// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module calc_tb;
  wire [15:0] LED;
  wire Z;
  reg CLC;
  reg C;
  reg L;
  reg U;
  reg R;
  reg D;
  reg [15:0] SW;
  
  calc calc_tb(LED,Z,CLC,C,L,U,R,D,SW);
  
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0,calc_tb);
    
    CLC=1'b0; 
    $display("SW | LED");
    
    U=1'b1;	//RESET. UP BUTTON IS PRESSED
    //doesn't matter what the rest are. x.
    #1 $write("%h | %h", SW, LED);
    if(LED==0) $display("PASS"); else $display ("FAIL");
    
    
    #20
    L=1'b0;
    C=1'b1;
    R=1'b0;
    U=1'b0;
    D=1'b1;
    SW=16'h354a;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h354a) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b0;
    C=1'b1;
    R=1'b1;
    U=1'b0;
    D=1'b1;
    SW=16'h1234;     
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h2316) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b0;
    C=1'b0;
    R=1'b1;
    U=1'b0;
    D=1'b1;
    SW=16'h1001;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h3317) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b0;
    C=1'b0;
    R=1'b0;
    U=1'b0;
    D=1'b1;
    SW=16'hf0f0;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h3010) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b1;
    C=1'b1;
    R=1'b1;
    U=1'b0;
    D=1'b1;
    SW=16'h1fa2;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h2fb2) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b0;
    C=1'b1;
    R=1'b0;
    U=1'b0;
    D=1'b1;
    SW=16'h6aa2;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h9a54) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b1;
    C=1'b0;
    R=1'b1;
    U=1'b0;
    D=1'b1;
    SW=16'h0004;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'ha540) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b1;
    C=1'b1;
    R=1'b0;
    U=1'b0;
    D=1'b1;
    SW=16'h0001;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'hd2a0) $display("PASS"); else $display ("FAIL");
    
    #20
    L=1'b1;
    C=1'b0;
    R=1'b0;
    U=1'b0;
    D=1'b1;
    SW=16'h46ff;
    #1 $write("%h | %h", SW, LED);
    if(LED==16'h0001) $display("PASS"); else $display ("FAIL");
    
    
  end
  
  initial #220 $finish;
  always #10 CLC=~CLC;
  
endmodule