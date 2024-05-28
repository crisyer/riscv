module pc_operand(
    input [31: 0] pc, 
    input [31:0] imm_32, rs1_data,

    output reg [31: 0] pc_add_imm_32, 
    output reg [31:0] rs1_data_add_imm_32_for_pc
  );
  always @(*)
  begin
    pc_add_imm_32 <= pc + imm_32;
    rs1_data_add_imm_32_for_pc <= rs1_data + imm_32;
  end
endmodule
