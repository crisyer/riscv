module ex_me(
    input clk,rst,flush,

    input  ex_write_reg_enable,
    input  ex_wb_aluOut_or_memOut,
    input  [1: 0] ex_write_ram_flag,
    input  [2: 0] ex_read_ram_flag,
    input  [1: 0] ex_pc_condition, // alu
    input ex_branch_enable,
    input [31:0] ex_pc_add_imm_32,  //ex
    input [31:0] ex_rs1_data_add_imm_32_for_pc,  //ex
    input [31:0] ex_alu_out,//new
    input [31:0] ex_rs2_data, // reg
    input [4: 0] ex_rd_addr,
    input [4: 0] ex_rs2_addr,

    output reg  me_write_reg_enable,
    output reg  me_wb_aluOut_or_memOut,
    output reg  [1: 0] me_write_ram_flag,
    output reg  [2: 0] me_read_ram_flag,
    output reg  [1: 0] me_pc_condition, // alu
    output reg me_branch_enable,
    output reg [31:0] me_alu_out,//new
    output reg [31:0] me_pc_add_imm_32,  //me
    output reg [31:0] me_rs1_data_add_imm_32_for_pc,  //me
    output reg [31:0] me_rs2_data, // reg
    output reg [4: 0] me_rd_addr,
    output reg [4: 0] me_rs2_addr
  );

  always @(posedge clk)
  begin
    if (rst || flush)
    begin
      me_write_reg_enable <= 0;
      me_wb_aluOut_or_memOut <= 0;
      me_write_ram_flag <= 0;
      me_read_ram_flag <= 0;
      me_pc_condition <= 0;
      me_branch_enable <= 0;
      me_alu_out <= 0;
      me_pc_add_imm_32 <= 0;
      me_rs1_data_add_imm_32_for_pc <= 0;
      me_rs2_data <= 0;
      me_rd_addr <= 0;
      me_rs2_addr <= 0;
    end
    else
    begin
      me_write_reg_enable <= ex_write_ram_flag;
      me_wb_aluOut_or_memOut <= ex_wb_aluOut_or_memOut;
      me_write_ram_flag <= ex_write_ram_flag;
      me_read_ram_flag <= ex_read_ram_flag;
      me_pc_condition <= ex_pc_condition;
      me_branch_enable <= ex_branch_enable;
      me_alu_out <= ex_alu_out;
      me_pc_add_imm_32 <= ex_pc_add_imm_32;
      me_rs1_data_add_imm_32_for_pc <= ex_rs1_data_add_imm_32_for_pc;
      me_rs2_data <= ex_rs2_data;
      me_rd_addr <= ex_rd_addr;
      me_rs2_addr <= ex_rs2_addr;
    end
  end

endmodule
