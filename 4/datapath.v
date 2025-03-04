`include "ALU.v"
`include "regfile.v"

module datapath(
  output reg [31:0] PC,
  output Zero,
  output [31:0] dAddress,
  output [31:0] dWriteData,
  output [31:0] WriteBackData,
  input clk,
  input rst,
  input [31:0] instr,
  input PCSrc,
  input ALUSrc,
  input RegWrite,
  input MemToReg,
  input [3:0] ALUCtrl,
  input loadPC,
  input [31:0] dReadData);
  
  parameter INITIAL_PC=32'h00400000; //0x00400000
  parameter opcode_R=7'b0110011; 
  parameter opcode_I=7'b0010011; 
  parameter opcode_S=7'b0100011;
  parameter opcode_B=7'b1100011;
  parameter opcode_LW=7'b0000011;//LW is type Immediate, but has different opcode
  
  
 
  //internal nets
  
  reg [4:0] i1;	//regfile input, readReg1
  reg [4:0] i2;	//regfile input, readReg2
  reg [4:0] i3;  //regfile input, writeReg 
  reg [11:0] imm12;  //immediate value
  reg [31:0] imm32;
  wire [31:0] n1;  //connects readData1 with op1 of ALU
  wire [31:0] n2;  //connects readData2 with the mux that decides whether ALU's second operant is an immediate value or a register's value, and with dWriteData of RAM.
  wire [31:0] n3;  //connects the output of the mux with op2 of ALU
  wire [31:0] n4;	//connects the ALU's result with dAddress of RAM, and with the mux that decides the value of WriteBackData
  //
  
  initial begin
    PC=INITIAL_PC;
  end
  
  always @(instr) begin		
    
  
    i1=instr[19:15]; //internal net that connects to readReg1
    i2=instr[24:20]; //internal net that connects to readReg2
    i3=instr[11:7]; //internal net that connects to writeReg
    
    if(instr[6:0]==opcode_I || instr[6:0]==opcode_LW) //imm gen
      imm12=instr[31:20]; //for I types
    else if(instr[6:0]==opcode_S)
      imm12={instr[31:25], instr[11:7]}; //for S types
    else if(instr[6:0]==opcode_B)
      imm12={instr[31],instr[7],instr[30:25],instr[11:8]}; //for B types
    else if(instr[6:0]==opcode_R)
      imm12=12'b000000000000;	//if it's an R type, no immediate value is used, so it doesn't matter what
    else begin							//imm12 is. Set it to 0 instead of x to avoid unpredictable behaviour.
      $display ("Invalid Opcode at Imm Gen");
      imm12=12'b000000000000;//new addition to the code
    end
    imm32={ {20{imm12[11]}},imm12 };
    
  end 
  
  regfile REGFL(.readData1(n1), .readData2(n2), .clk(clk), .readReg1(i1), .readReg2(i2), .writeReg(i3) , .writeData(WriteBackData), .write(RegWrite));
  mux MUX1(.chosen(n3), .option0(n2), .option1(imm32), .control(ALUSrc));//If ALUSrc=0, ALU gets rs2, otherwise ALU gets immediate data
  ALU ALU_DATAPATH (.result(n4), .zero(Zero), .op1(n1), .op2(n3), .alu_op(ALUCtrl) );
  
  assign dWriteData=n2;	//wires can't be assigned values inside always blocks
  assign dAddress=n4;		//n4 is the result output of the ALU

  
  mux MUX2(.chosen(WriteBackData), .option0(n4), .option1(dReadData), .control(MemToReg));
      
  always @(posedge clk) begin
    if (!rst)
      PC<=INITIAL_PC;
      
    else if(loadPC) begin
      if(PCSrc) //multiplexer 
        PC<=PC+(imm32<<1);//PC + branch_offset (Branch Target)
      else 
        PC<=PC+4;//PC + 4 (όταν το πρόγραμμα προχωρά στην επόμενη εντολή στη μνήμη)
    end
  end        
      
endmodule    
        
      
module mux(
  output wire [31:0] chosen,
  input wire [31:0] option0,
  input wire [31:0] option1,
  input wire control);     
        
  assign chosen=(control) ? (option1) : (option0);
												
endmodule
