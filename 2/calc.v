`include "ALU.v"
`include "calc_enc.v"

module calc(
  output [15:0] led,
  output z,
  input clc,
  input btnc,
  input btnl,
  input btnu,
  input btnr,
  input btnd,
  input [15:0] sw);
  
  wire [3:0] n1;//internal wires
  wire [31:0] n2;
  wire [31:0] n3;
  wire [15:0] n4;
  wire [31:0] n5;
  
  sign_extend ex1(.ext_bit32(n5), .bit16(n4));
  sign_extend ex2(.ext_bit32(n2), .bit16(sw));
  
  calc_enc ALU_CONTROL(.alu_op(n1), .btnl(btnl), .btnc(btnc), .btnr(btnr));
  
  ALU alu( .result(n3), .zero(z), .op1(n5), .op2(n2), .alu_op(n1) );
  
  accumulator ACC( .acc_out(n4), .clc(clc), .btnu(btnu), .btnd(btnd), .data_in(n3[15:0]) );
  
  assign led = n4;
          
endmodule

module accumulator (
  output reg [15:0] acc_out,
  input wire clc, 
  input wire btnu,
  input wire btnd,
  input wire [15:0] data_in);
  
  always @(posedge clc) begin
    if(btnu)
       acc_out <= 16'b0;
    else if(btnd)
      acc_out<=data_in;
  end  
  
endmodule 

module sign_extend(
  output wire [31:0] ext_bit32,
  input wire [15:0] bit16);
  
   assign ext_bit32= { {16{bit16[15]}},bit16 };
  
endmodule  
