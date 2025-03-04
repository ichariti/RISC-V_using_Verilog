module ALU(
  output [31:0] result,
  output zero,
  input [31:0] op1,
  input [31:0] op2,
  input [3:0] alu_op);

  parameter[3:0] ALUOP_AND = 4'b0000;
  parameter[3:0] ALUOP_OR = 4'b0001;
  parameter[3:0] ALUOP_ADD = 4'b0010;
  parameter[3:0] ALUOP_SUB = 4'b0110;
  parameter[3:0] ALUOP_LT = 4'b0100;
  parameter[3:0] ALUOP_Rsh = 4'b1000;
  parameter[3:0] ALUOP_Lsh = 4'b1001;
  parameter[3:0] ALUOP_NRsh = 4'b1010;
  parameter[3:0] ALUOP_XOR = 4'b0101;

assign result=(alu_op == ALUOP_AND) ? (op1&op2):
		 (alu_op == ALUOP_OR) ? (op1|op2):
		 (alu_op == ALUOP_ADD) ? (op1+op2):
		 (alu_op == ALUOP_SUB) ? (op1-op2):
		 (alu_op == ALUOP_LT) ? ($signed(op1)<$signed(op2)):
		 (alu_op == ALUOP_Rsh) ? (op1>>op2[4:0]):
		 (alu_op == ALUOP_Lsh) ? (op1<<op2[4:0]):
		 (alu_op == ALUOP_NRsh) ? ($unsigned($signed(op1)>>>op2[4:0])):
		 (alu_op == ALUOP_XOR) ? (op1^op2):
  		 (1'bX);
  assign zero=(result == 32'b0) ? (1'b1):(1'b0);

endmodule