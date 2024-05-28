`timescale 1ns / 1ps
`include "ram.v"
`include "rom.v"
`include "pc.v"
`include "pc_controller.v"
`include "controller.v"
`include "imm_gen.v"
`include "regs.v"
`include "id.v"
`include "alu.v"
`include "mux_3.v"
`include "mux_2.v"
module cpu(
    input clk, rst
);

// 数据
wire [31: 0] instr; // 指令
wire [31: 0] write_rd_data; // 即将写入寄存器 rd数据
wire [31: 0] rs1_data; // 寄存器 rs1的数据
wire [31: 0] rs2_data; // 寄存器 rs2的数据
wire [31: 0] imm_32; // 32位立即数
wire [31: 0] in_alu_a; // 输入给运算器的 a端口
wire [31: 0] in_alu_b; // 输入给运算器的 b端口
wire [31: 0] out_alu; // ALU的运算结果
wire [31: 0] ram_out; // 从内存中读的数据
wire [31: 0] pc; // 当前指令的内存地址

wire [31:0] pc_rom_addr;


wire [4:  0] rd_addr, rs1_addr, rs2_addr; // 寄存器地址
wire [6: 0] opcode;
wire [2: 0] func3;
wire [6: 0] func7;

// 控制信号
wire [4:  0] alu_opt; // 控制 ALU运算
wire  load_ram_enable; // 二路选择器
wire  alu_a_in; // 二路选择器
wire  [1:0] alu_b_in; // 三路选择器
wire write_reg_enable; // 寄存器写信号
wire [1: 0] write_ram_flag; // 写内存信号
wire [2: 0] read_ram_flag; // 读内存信号
wire[1: 0] pc_condition;
wire [31: 0] next_pc;
wire branch_enable; // 条件跳转

wire [31:0]  reg_1;
wire [31:0]  reg_2;
wire [31:0]  reg_3;
wire [31:0]  reg_4;
wire [31:0]  reg_5;
wire [31:0]  reg_6;
wire [31:0]  reg_7;
wire [31:0]  reg_8;
wire [31:0]  reg_9;
wire [31:0]  reg_10;
wire [31:0]  reg_11;
wire [31:0]  reg_12;
wire [31:0]  reg_13;
wire [31:0]  reg_14;
wire [31:0]  reg_15;
wire [31:0]  reg_0;

wire [31:0] ram_0;
wire [31:0] ram_1;
wire [31:0] ram_2;
wire [31:0] ram_3;
wire [31:0] ram_4;
wire [31:0] ram_5;
wire [31:0] ram_6;
wire [31:0] ram_7;
wire [31:0] ram_8;


pc PC_INSTANCE(
    .rst(rst),
    .clk(clk),
    .next_pc(next_pc),

    .pc(pc),
    .pc_rom_addr(pc_rom_addr)
);

pc_controller NEXT_PC_INSTANCE(
    .clk(clk),
    .rst(rst),
    .pc_condition(pc_condition),
    .branch_enable(branch_enable),
    .pc(pc),
    .imm_32(imm_32),
    .rs1_data(rs1_data),

  .next_pc(next_pc)
);

id ID_INSTANCE(
    .instr(instr),

    // 译码的相关数据
    .opcode(opcode),
    .func3(func3),
    .func7(func7),
    .rd_addr(rd_addr),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr)
);

imm_gen IMM_INSTANCE(
    .instr(instr),

    .imm_32(imm_32)
);


controller CONTROLLER_INSTANCE(
    .opcode(opcode),
    .func3(func3),
    .func7(func7),

    .alu_opt(alu_opt),
    .load_ram_enable(load_ram_enable),
    .alu_a_in(alu_a_in),
    .alu_b_in(alu_b_in),
    .write_reg_enable(write_reg_enable),
    .write_ram_flag(write_ram_flag),
    .read_ram_flag(read_ram_flag),
    .pc_condition(pc_condition)
);

alu ALU_INSTANCE(
    .alu_opt(alu_opt),
    .a(in_alu_a),
    .b(in_alu_b),

    .out(out_alu),
    .branch_enable(branch_enable)
);


mux_2 MUX_WB_INSTANCE(
    .signal(load_ram_enable),
    .a(out_alu),
    .b(ram_out),

    .out(write_rd_data)
);

mux_3 MUX_ALU_B_INSTANCE(
    .signal(alu_b_in),
    .a(rs2_data),
    .b(imm_32),
    .c(32'd4),

    .out(in_alu_b)
);

mux_2 MUX_ALU_A_INSTANCE(
    .signal(alu_a_in),
    .a(rs1_data),
    .b(pc),

    .out(in_alu_a)
);

regs REG_FILE_INSTANCE(
    .rst(rst),
    .clk(clk),
    .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr),
    .rd_addr(rd_addr),
    .write_reg_enable(write_reg_enable),
    .writ_data(write_rd_data),

    .rs1_data(rs1_data),
    .rs2_data(rs2_data),

    .reg_0(reg_0),
    .reg_1(reg_1),
    .reg_2(reg_2),
    .reg_3(reg_3),
    .reg_4(reg_4),
    .reg_5(reg_5),
    .reg_6(reg_6),
    .reg_7(reg_7),
    .reg_8(reg_8),
    .reg_9(reg_9),
    .reg_10(reg_10),
    .reg_11(reg_11),
    .reg_12(reg_12),
    .reg_13(reg_13),
    .reg_14(reg_14),
    .reg_15(reg_15)
);

ram RAM_INSTANCE(
    .clk(clk),
    .rst(rst),
    .ram_addr(out_alu),
    .write_ram_data(rs2_data),
    .write_ram_flag(write_ram_flag),
    .read_ram_flag(read_ram_flag),

    .ram_out(ram_out),

    .ram_0(ram_0),
    .ram_1(ram_1),
    .ram_2(ram_2),
    .ram_3(ram_3),
    .ram_4(ram_4),
    .ram_5(ram_5),
    .ram_6(ram_6),
    .ram_7(ram_7),
    .ram_8(ram_8)
);

rom ROM_INSTANCE(
    .pc(pc),
    .instr(instr)
);
endmodule