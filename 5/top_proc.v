`include "datapath.v"

module top_proc(
  output reg [31:0] PC,
  output [31:0] dAddress,
  output [31:0] dWriteData,
  output reg MemRead,
  output reg MemWrite,
  output [31:0] WriteBackData,
  input clk,
  input rst,
  input [31:0] instr,
  input [31:0] dReadData);
  
   parameter INITIAL_PC=32'h00400000;
   parameter opcode_R=7'b0110011; 
   parameter opcode_I=7'b0010011; 
   parameter opcode_S=7'b0100011;
   parameter opcode_B=7'b1100011;
   parameter opcode_LW=7'b0000011;//LW is type Immediate, but has different opcode

  
  //for FSM
  reg [2:0] current_state;
  reg [2:0] next_state;
  parameter IF=3'b000;
  parameter ID=3'b001;
  parameter EX=3'b010;
  parameter MEM=3'b011;
  parameter WB=3'b100;
  //
  
  //internal nets (parts of instr, and all control signals except MemRead MemWrite)
  wire [6:0] opcode;
  wire funct7;
  wire [2:0] funct3;
  reg [3:0] ALUCtrl;
  reg [2:0] ALUOp;
  reg ALUSrc;
  reg RegWrite;
  reg MemToReg;
  reg loadPC;
  reg Branch;
  wire Zero;
  wire PCSrc;
  //
  assign opcode=instr[6:0];
  assign funct7=instr[30];
  assign funct3=instr[14:12];
  assign PCSrc=Zero&Branch;
  
  always @(opcode) begin	//CONTROL UNIT (signals independent of the FSM state)
    case (opcode)
      opcode_R : begin
        ALUOp=3'b000;
        ALUSrc=1'b0;
        Branch=1'b0;
      end
      opcode_I : begin
        ALUOp=3'b001;
        ALUSrc=1'b1;
        Branch=1'b0;
      end
      opcode_S : begin
        ALUOp=3'b010;
        ALUSrc=1'b1;
        Branch=1'b0;
      end
      opcode_B : begin
        ALUOp=3'b011;
        ALUSrc=1'b0;
        Branch=1'b1;
      end
      opcode_LW : begin
        ALUOp=3'b100;
        ALUSrc=1'b1;
        Branch=1'b0;
      end
      default : begin
        ALUOp=3'b001;	//invalid opcodes are handled by the ALU like type I, with an imm field of 0 (imm gen in datapath assigns zero to imm12 if the opcode is trash)
        ALUSrc=1'b1;
        Branch=1'b0;
      end
    endcase
    
  end
  
  always @(ALUOp,funct7,funct3) begin  //ALU CONTROL
    casex({ALUOp,funct7,funct3})
      12'b0000111, 12'b001x111 : ALUCtrl = 4'b0000;	//AND
      12'b0000110, 12'b001x110 : ALUCtrl = 4'b0001;	//OR
      12'b011x000, 12'b0001000 : ALUCtrl = 4'b0110;	//SUBTRACTION
      12'b0000010, 12'b001x010 : ALUCtrl = 4'b0100;	//LESS THAN
      12'b0000101, 12'b0010101 : ALUCtrl = 4'b1000;	//SHIFT RIGHT LOGICAL
      12'b0000001, 12'b0010001 : ALUCtrl = 4'b1001;	//SHIFT LEFT LOGICAL
      12'b0001101, 12'b0011101 : ALUCtrl = 4'b1010;	//SHIFT RIGHT ARITHMETIC
      12'b0000100, 12'b001x100 : ALUCtrl = 4'b0101;	//XOR
      12'b100x010: ALUCtrl=4'b0010;//LW requires addition
      default : ALUCtrl = 4'b0010;	//ADDITION (anything valid left requires addition. Anything invalid needs a default.)
    endcase							//Invalid commands are treated like a type I with imm32=0. it's important for MemWrite and RegWrite to be low, so no changes
  end								//are made to the regfile or the data memory by a nonsense command
  									
  
   //Όταν αρχικοποιήσετε το datapath σας, θα πρέπει να περάσετε την παράμετρο INITIAL_PC της μονάδας top_proc στη μονάδα datapath σας. HOW???
  datapath DATAPATH(.PC(PC), .Zero(Zero), .dAddress(dAddress), .dWriteData(dWriteData), .WriteBackData(WriteBackData), .clk(clk), .rst(rst), .instr(instr), .PCSrc(PCSrc), .ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemToReg(MemToReg), .ALUCtrl(ALUCtrl), .loadPC(loadPC), .dReadData(dReadData));
  
  //FSM
  always @(posedge clk)
    begin: STATE_MEMORY
      if(!rst)	//synchronous reset, δεν ειναι στη λιστα ευαισθησίας 
        current_state<=IF;
      else
        current_state<=next_state;
    end
  
  always @(current_state or instr or dReadData)
    begin: NEXT_STATE_LOGIC		//what needs to happen for the state to change? inputs? clock?
      case (current_state)
        IF: next_state=ID;
        ID: next_state=EX;
        EX: begin
          next_state=MEM;
          //if (instr[6:0]~=opcode_S && instr[6:0]~=opcode_LW) next_state=WB; //only load and store commands use the MEM state
          //else next_state=MEM;	//do we have to skip it or can the control signals ensure no trash? this saves us one extra cycle for most command
        end
        MEM: next_state=WB;
        WB: next_state=IF;
        default: next_state=IF;
      endcase
    end
  
  always @(current_state or instr or dReadData)
    begin: OUTPUT_LOGIC			//what are the outputs of each state?
      case (current_state)
        IF: begin
          loadPC=1'b0;
          MemRead=1'b0;
          MemWrite=1'b0;
          MemToReg=1'b0;
          RegWrite=1'b0;
        end
        
        ID: begin
          loadPC=1'b0;
          MemRead=1'b0;
          MemWrite=1'b0;
          MemToReg=1'b0;
          RegWrite=1'b0;
        end
       
        EX:begin
          loadPC=1'b0;
          MemRead=1'b0;
          MemWrite=1'b0;
          MemToReg=1'b0;
          RegWrite=1'b0;
        end
       
        MEM: begin
          if(opcode==opcode_LW)	//set MemRead to high for load instructions during MEM state
            MemRead=1'b1;
          else
            MemRead=1'b0;
          if (opcode==opcode_S)	//set MemWrite to high for store instructions during MEM state
            MemWrite=1'b1;
          else
            MemWrite=1'b0;
          
          MemToReg=1'b0;
          loadPC=1'b0;
          RegWrite=1'b0;
        end
        
        WB: begin 
          if(opcode==opcode_LW || opcode==opcode_I || opcode==opcode_R)
            RegWrite=1'b1;	//set RegWrite to high for instructions with a destination register (rd)
          else				//during SW state
            RegWrite=1'b0;	//set RegWrite to low for other instructions, or if the opcode is invalid
          if(opcode==opcode_LW)
            MemToReg=1'b1;
          else
            MemToReg=1'b0;
            
          loadPC=1'b1;
          MemRead=1'b0;
          MemWrite=1'b0;
        end
        
        default:begin
          loadPC=1'b0;
          MemRead=1'b0;
          MemWrite=1'b0;
          MemToReg=1'b0;
          RegWrite=1'b0;
        end
          
      endcase
    end
          
          
endmodule

