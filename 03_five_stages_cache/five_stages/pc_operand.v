module pc_operand(
    input [31: 0] pc, 
    input [31:0] imm_32, rs1_data,
    input pc_from_rom_ready,
    output reg [31: 0] pc_add_imm_32, 
    output reg [31:0] rs1_data_add_imm_32_for_pc
  );
  always @(*)
  begin
    if (pc_from_rom_ready) begin
        pc_add_imm_32 <= pc + imm_32;
        rs1_data_add_imm_32_for_pc <= rs1_data + imm_32;
    end
    else begin
      pc_add_imm_32 <= pc_add_imm_32;
      rs1_data_add_imm_32_for_pc <= rs1_data_add_imm_32_for_pc;
    end
  end
endmodule
