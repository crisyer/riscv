module id_ex(
    input clk,rst,flush,pause,

    input  [4: 0] id_alu_opt,
    input  id_wb_aluOut_or_memOut,
    input  id_alu_a_in_rs1_or_pc,
    input  [1: 0] id_alu_b_in_rs2Data_or_imm32_or_4,
    input  id_write_reg_enable,
    input  [1: 0] id_write_ram_flag,
    input  [2: 0] id_load_ram_flag,
    input  [1: 0] id_pc_condition, // controller
    input [31:0] id_pc,  // pc
    input [4: 0] id_rd_addr,
    input [4: 0] id_rs1_addr,
    input [4: 0] id_rs2_addr,
    input [31:0] id_imm_32,  //id
    input  [31:0] id_rs1_data,
    input [31:0] id_rs2_data, // reg

    output reg [4: 0] ex_alu_opt,
    output reg ex_alu_a_in_rs1_or_pc,
    output reg [1: 0] ex_alu_b_in_rs2Data_or_imm32_or_4,
    output reg ex_write_reg_enable,
    output reg [1: 0] ex_write_ram_flag,
    output reg ex_wb_aluOut_or_memOut,
    output reg [2: 0] ex_load_ram_flag,
    output reg [1: 0] ex_pc_condition, // controller
    output reg [31:0] ex_pc, // pc
    output reg [4: 0] ex_rd_addr,
    output reg [4: 0] ex_rs1_addr,
    output reg [4: 0] ex_rs2_addr,
    output reg [31:0] ex_imm_32, //id
    output reg  [31:0] ex_rs1_data,
    output reg [31:0] ex_rs2_data // reg
  );

  always @(posedge clk)
  begin
    if (rst || pause || flush)
    begin
      ex_alu_opt <= 0;
      ex_alu_a_in_rs1_or_pc <= 0;
      ex_alu_b_in_rs2Data_or_imm32_or_4 <= 0;
      ex_write_reg_enable <= 0;
      ex_write_ram_flag <= 0;
      ex_wb_aluOut_or_memOut <= 0;
      ex_load_ram_flag <= 0;
      ex_pc_condition <= 0;
      ex_pc <= 0;
      ex_rd_addr <= 0;
      ex_rs1_addr <= 0;
      ex_rs2_addr <= 0;
      ex_imm_32 <= 0;
      ex_rs1_data <= 0;
      ex_rs2_data <= 0;
    end
    else
    begin
      ex_alu_opt <= id_alu_opt;
      ex_alu_a_in_rs1_or_pc <= id_alu_a_in_rs1_or_pc;
      ex_alu_b_in_rs2Data_or_imm32_or_4 <= id_alu_b_in_rs2Data_or_imm32_or_4;
      ex_write_reg_enable <= id_write_reg_enable;
      ex_write_ram_flag <= id_write_ram_flag;
      ex_wb_aluOut_or_memOut <= id_wb_aluOut_or_memOut;
      ex_load_ram_flag <= id_load_ram_flag;
      ex_pc_condition <= id_pc_condition;
      ex_pc <= id_pc;
      ex_rd_addr <= id_rd_addr;
      ex_rs1_addr <= id_rs1_addr;
      ex_rs2_addr <= id_rs2_addr;
      ex_imm_32 <= id_imm_32;
      ex_rs1_data <= id_rs1_data;
      ex_rs2_data <= id_rs2_data;
    end
  end

endmodule
