module bit0(
  output wire zeroBit,
  input wire C,
  input wire R, 
  input wire L);
  
  wire Cn;
  wire m1;
  wire m2;
  
  not N0(Cn,C);
  and A0_1(m1,Cn,R);
  and A0_2(m2,L,R);
  or O0(zeroBit,m1,m2);
  
endmodule

module bit1(
  output wire oneBit,
  input wire C,
  input wire R, 
  input wire L);
  
  wire Ln;
  wire Rn;
  wire m3;
  wire m4;
  
  not N1_1(Ln,L);
  not N1_2(Rn,R);
  and A1_1(m3,Ln,C);
  and A1_2(m4,C,Rn);
  or O1(oneBit,m3,m4);
  
endmodule

module bit2(
  output wire twoBit,
  input wire C,
  input wire R, 
  input wire L);
  
  wire Cn;
  wire Rn;
  wire m5;
  wire m6;
  wire m7;
  
  not N2_1(Cn,C);
  not N2_2(Rn,R);
  and A2_1(m5,C,R);
  and A2_2(m6,L,Cn);
  and A2_3(m7,m6,Rn);
  
  or O2(twoBit,m5,m7);
  
endmodule

module bit3(
  output wire threeBit,
  input wire C,
  input wire R, 
  input wire L);
  
  wire Cn;
  wire Rn;
  wire m8;
  wire m9;
  wire m10;
  wire m11;
  
  not N3_1(Cn,C);
  not N3_2(Rn,R);
  and A3_1(m8,L,Cn);
  and A3_2(m11,m8,R);
  and A3_3(m9,L,C);
  and A3_4(m10,m9,Rn);
  
  or O3(threeBit,m11,m10);
  
endmodule

module calc_enc(
  output wire [3:0] alu_op,
  input wire btnl,
  input wire btnc, 
  input wire btnr);
  
  bit0 zero(.zeroBit(alu_op[0]), .C(btnc), .R(btnr), .L(btnl));
  bit1 one(.oneBit(alu_op[1]), .C(btnc), .R(btnr), .L(btnl));
  bit2 two(.twoBit(alu_op[2]), .C(btnc), .R(btnr), .L(btnl));
  bit3 three(.threeBit(alu_op[3]), .C(btnc), .R(btnr), .L(btnl));
    
endmodule