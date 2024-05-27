module imm_gen(
    input 	    [31:0] instr,
    output reg	[31:0] imm_32
  );
  wire	[6:0] opcode;
  assign	opcode= instr[6:0];
  //立即数扩展
  always@(*)
  begin
    case(opcode)
      7'b0010111:
        imm_32<={instr[31:12],12'b0};
      7'b0110111:
        imm_32<={instr[31:12],12'b0};
      7'b1100011:
        imm_32<={{20{instr[31]}},instr[7],instr[30:25],instr[11:8],1'b0};
      7'b1101111:
        imm_32<={{12{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
      7'b1100111:
        imm_32<={{20{instr[31]}},instr[31:20]};
      7'b0000011:
        imm_32<={{20{instr[31]}},instr[31:20]};
      7'b0100011:
        imm_32<={{20{instr[31]}},instr[31:25],instr[11:7]};
      7'b0010011:
        imm_32<={{20{instr[31]}},instr[31:20]};
      7'b0110011:
        imm_32<={{20{instr[31]}},instr[31:20]};
      default:
        imm_32<=32'h0;
    endcase
  end
endmodule
