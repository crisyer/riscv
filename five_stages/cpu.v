`timescale 1ns / 1ps
`include "ram.v"
`include "rom.v"
`include "pc.v"
`include "next_pc.v"
`include "controller.v"
`include "imm_gen.v"
`include "regs.v"
`include "id.v"
`include "alu.v"
`include "mux_3.v"
`include "mux_2.v"
`include "pc_operand.v"
`include "pc_add_four.v"
`include "if_id.v"
`include "id_ex.v"
`include "ex_me.v"
`include "me_wb.v"
`include "hazard_detection_unit.v"
`include "forward_unit.v"

module cpu(
    input clk, rst
);

// 冒险
wire pause; // 数据冒险 停顿
wire flush; // 控制冒险 刷新
wire [1:0] forwardA, forwardB; // 数据冒险旁路
wire forwardC; // 数据冒险旁路


// 取指令阶段
wire [31:0] if_pc; // 指令地址
wire [31:0] if_pc_add_4; // pc + 4
wire [31:0] if_next_pc; // 下一条指令的地址
wire [31:0] if_instr; // 阶段的指令
// 译码阶段
wire [31: 0] id_pc; // 指令地址
wire [31: 0] id_instr; // 指令
    // pc
wire [31: 0] id_imm_32; // 32位立即数
    // imm_gen
wire [31: 0] id_rs1_data; //寄存器rs1的数据
wire [31: 0] id_rs2_data; // 寄存器rs2的数据:先写后读
wire [4:  0] id_rd_addr, id_rs1_addr, id_rs2_addr; // 寄存器地址
    // reg
wire [6: 0] id_opcode; // 操作码
wire [2: 0] id_func3; 
wire [6: 0] id_func7;
    // id
wire [4:  0] id_alu_opt; // 控制 ALU运算
wire id_wb_aluOut_or_memOut; // 二路选择器
wire id_alu_a_in_rs1_or_pc; // 二路选择器
wire[1: 0] id_alu_b_in_rs2Data_or_imm32_or_4; // 三路选择器
wire id_write_reg_enable; // 寄存器写信号
wire [1: 0] id_write_ram_flag; // 写内存信号
wire [2: 0] id_read_ram_flag; // 读内存信号
wire [1: 0] id_pc_condition; // 无条件跳转
    // controller


// 执行阶段
wire [4:  0] ex_alu_opt; // 控制 ALU运算
wire ex_wb_aluOut_or_memOut; // 二路选择器
wire ex_alu_a_in_rs1_or_pc; // 二路选择器
wire[1: 0] ex_alu_b_in_rs2Data_or_imm32_or_4; // 三路选择器
wire ex_write_reg_enable; // 寄存器写信号
    // controller
wire [1: 0] ex_write_ram_flag; // 写内存信号
wire [2: 0] ex_read_ram_flag; // 读内存信号
    // ram
wire[1: 0] ex_pc_condition; // 无条件跳转
wire [31: 0] ex_pc; 
wire [31: 0] ex_rs1_data, ex_rs2_data;
wire [31: 0] ex_true_rs1_data, ex_true_rs2_data; //todo
wire [31: 0] ex_imm_32;
wire [4: 0] ex_rd_addr, ex_rs1_addr, ex_rs2_addr;
wire [31: 0] ex_inAluA, ex_inAluB; // ALU的输入
wire [31: 0] ex_pc_add_imm_32, ex_rs1_data_add_imm_32_for_pc; // add_pc
wire [31: 0] ex_alu_out; // ALu的输出
wire ex_branch_enable; // 条件分支

// 访存阶段
wire me_wb_aluOut_or_memOut; // 二路选择器
wire me_write_reg_enable; // 寄存器写信号
wire [1: 0] me_write_ram_flag; // 写内存信号
wire [2: 0] me_read_ram_flag; // 读内存信号
wire[1: 0] me_pc_condition; // 无条件跳转
wire me_branch_enable; // 条件分支
wire [31: 0] me_pc_add_imm_32, me_rs1_data_add_imm_32_for_pc; // 分支
wire [31: 0] me_alu_out; // ALu的输出
wire [31: 0] me_rs2_data;
wire [4: 0] me_rd_addr;
wire [4: 0] me_rs2_addr;
wire [31: 0] me_true_rs2_data;
wire [31: 0] me_ram_out;

// 写回阶段
wire wb_wb_aluOut_or_memOut; 
wire wb_write_reg_enable;
wire [31: 0] wb_ram_out;
wire [31: 0] wb_alu_out;
wire [31: 0] wb_rd_write_data;
wire [4: 0] wb_rd_addr;

// debug
wire [31:0] pc_rom_addr;

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


next_pc NEXT_PC_INSTANCE(
    .branch_enable(me_branch_enable),
    .pc_condition(me_pc_condition),

    .pc_add_four(if_pc_add_4),
    .pc_add_imm_32(me_pc_add_imm_32),
    .rs1_data_add_imm_32_for_pc(me_rs1_data_add_imm_32_for_pc),

    .next_pc(if_next_pc),
    .flush(flush)
);



pc_add_four PC_ADD_4_INSTANCE(
    .pc(if_pc),
    .pc_add_four(if_pc_add_4)
);


pc PC_INSTANCE(
    .rst(rst),
    .clk(clk),
    .pause(pause),

    .next_pc(if_next_pc),

    .pc(if_pc),
    //debug
    .pc_rom_addr(pc_rom_addr)
);

rom ROM_INSTANCE(
    .pc(if_pc),
    .instr(if_instr)
);

// **************************** 
//    if-id 寄存器
// **************************** 
if_id IF_ID_INSTANCE(
    .clk(clk),
    .rst(rst),
    .pause(pause),
    .flush(flush),

    .if_pc(if_pc),
    .if_instr(if_instr),

    .id_pc(id_pc),
    .id_instr(id_instr)
);


id ID_INSTANCE(
    .instr(id_instr),

    // 译码的相关数据
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),

    .rd_addr(id_rd_addr),
    .rs1_addr(id_rs1_addr),
    .rs2_addr(id_rs2_addr)
);


controller CONTROLLER_INSTANCE(
    .opcode(id_opcode),
    .func3(id_func3),
    .func7(id_func7),

    .alu_opt(id_alu_opt),

    .wb_aluOut_or_memOut(id_wb_aluOut_or_memOut),
    .alu_a_in_rs1_or_pc(id_alu_a_in_rs1_or_pc),
    .alu_b_in_rs2Data_or_imm32_or_4(id_alu_b_in_rs2Data_or_imm32_or_4),
    .write_reg_enable(id_write_reg_enable),
    .write_ram_flag(id_write_ram_flag),
    .read_ram_flag(id_read_ram_flag),
    .pc_condition(id_pc_condition)
);

regs REG_FILE(
    .rst(rst),
    .clk(clk),
    .write_reg_enable(wb_write_reg_enable),
    .rs1_addr(id_rs1_addr),
    .rs2_addr(id_rs2_addr),
    .rd_addr(id_rd_addr),
    .rd_write_data(wb_rd_write_data),

    .rs1_data(id_rs1_data),
    .rs2_data(id_rs2_data),

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

imm_gen IMM_INSTANCE(
    .instr(id_instr),

    .imm_32(id_imm_32)
);

hazard_detection_unit HAZARD_DETECTION_UNIT(
    .ex_read_ram_flag(ex_read_ram_flag),
    .ex_rd_addr(ex_rd_addr),
    .id_rs1_addr(id_rs1_addr),
    .id_rs2_addr(id_rs2_addr),

    .pause(pause)
);


// **************************** 
//    id -- ex 寄存器
// **************************** 

id_ex ID_EX_INSTANCE(
    .clk(clk),
    .rst(rst),
    .pause(pause),
    .flush(flush),

    .id_alu_opt(id_alu_opt),
    .id_wb_aluOut_or_memOut(id_wb_aluOut_or_memOut),
    .id_alu_a_in_rs1_or_pc(id_alu_a_in_rs1_or_pc),
    .id_alu_b_in_rs2Data_or_imm32_or_4(id_alu_b_in_rs2Data_or_imm32_or_4),
    .id_write_reg_enable(id_write_reg_enable),
    .id_write_ram_flag(id_write_ram_flag),
    .id_read_ram_flag(id_read_ram_flag),
    .id_pc_condition(id_pc_condition),
    .id_pc(id_pc),
    .id_rd_addr(id_rd_addr),
    .id_rs1_addr(id_rs1_addr),
    .id_rs2_addr(id_rs2_addr),
    .id_imm_32(id_imm_32),

    .id_rs1_data(id_rs1_data),
    .id_rs2_data(id_rs2_data),

    .ex_alu_opt(ex_alu_opt),
    .ex_wb_aluOut_or_memOut(ex_wb_aluOut_or_memOut),
    .ex_alu_a_in_rs1_or_pc(ex_alu_a_in_rs1_or_pc),
    .ex_alu_b_in_rs2Data_or_imm32_or_4(ex_alu_b_in_rs2Data_or_imm32_or_4),
    .ex_write_reg_enable(ex_write_reg_enable),
    .ex_write_ram_flag(ex_write_ram_flag),
    .ex_read_ram_flag(ex_read_ram_flag),
    .ex_pc_condition(ex_pc_condition),
    .ex_pc(ex_pc),
    .ex_rd_addr(ex_rd_addr),
    .ex_rs1_addr(ex_rs1_addr),
    .ex_rs2_addr(ex_rs2_addr),
    .ex_imm_32(ex_imm_32),

    .ex_rs1_data(ex_rs1_data),
    .ex_rs2_data(ex_rs2_data)
);

mux_3 MUX_FORWARD_A(
    .signal(forwardA),
    .a(ex_rs1_data),
    .b(me_alu_out),
    .c(wb_rd_write_data),

    .out(ex_true_rs1_data)
);


mux_3 MUX_FORWARD_B(
    .signal(forwardB),
    .a(ex_rs2_data),
    .b(me_alu_out),
    .c(wb_rd_write_data),

    .out(ex_true_rs2_data)
);



mux_2 MUX_ALU_A_INSTANCE(
    .signal(ex_alu_a_in_rs1_or_pc),
    .a(ex_true_rs1_data),
    .b(ex_pc),

    .out(ex_inAluA)
);

mux_3 MUX_ALU_B_INSTANCE(
    .signal(ex_alu_b_in_rs2Data_or_imm32_or_4),
    .a(ex_true_rs2_data),
    .b(ex_imm_32),
    .c(32'd4),

    .out(ex_inAluB)
);


pc_operand PC_OPERAND_INSTANCE(
    .pc(ex_pc),
    .imm_32(ex_imm_32),
    .rs1_data(ex_true_rs1_data),

    .pc_add_imm_32(ex_pc_add_imm_32),    
    .rs1_data_add_imm_32_for_pc(ex_rs1_data_add_imm_32_for_pc)
);

alu ALU_INSTANCE(
    .alu_opt(ex_alu_opt),
    .a(ex_inAluA),
    .b(ex_inAluB), 

    .alu_out(ex_alu_out),
    .branch_enable(ex_branch_enable)
);

forward_unit FORWARD_UNIT(
    .me_write_reg_enable(me_write_reg_enable),
    .me_rd_addr(me_rd_addr),
    .wb_rd_addr(wb_rd_addr),
    .wb_write_reg_enable(wb_write_reg_enable),
    .ex_rs1_addr(ex_rs1_addr),
    .ex_rs2_addr(ex_rs2_addr),
    .me_rs2_addr(me_rs2_addr),

    .ex_forwardA(forwardA),
    .ex_forwardB(forwardB),
    .me_forwardC(forwardC)
);


// ********************************
//         ex_me 寄存器
// ********************************

ex_me EX_ME(
    .clk(clk),
    .rst(rst),
    .flush(flush),

    .ex_write_reg_enable(ex_write_reg_enable),
    .ex_wb_aluOut_or_memOut(ex_wb_aluOut_or_memOut),
    .ex_write_ram_flag(ex_write_ram_flag),
    .ex_read_ram_flag(ex_read_ram_flag),
    .ex_pc_condition(ex_pc_condition),
    .ex_branch_enable(ex_branch_enable),
    .ex_pc_add_imm_32(ex_pc_add_imm_32),
    .ex_rs1_data_add_imm_32_for_pc(ex_rs1_data_add_imm_32_for_pc),
    .ex_alu_out(ex_alu_out),
    .ex_rs2_data(ex_true_rs2_data),
    .ex_rd_addr(ex_rd_addr),
    .ex_rs2_addr(ex_rs2_addr),

    .me_write_reg_enable(me_write_reg_enable),
    .me_wb_aluOut_or_memOut(me_wb_aluOut_or_memOut),
    .me_write_ram_flag(me_write_ram_flag),
    .me_read_ram_flag(me_read_ram_flag),
    .me_pc_condition(me_pc_condition),
    .me_branch_enable(me_branch_enable),
    .me_pc_add_imm_32(me_pc_add_imm_32),
    .me_rs1_data_add_imm_32_for_pc(me_rs1_data_add_imm_32_for_pc),
    .me_alu_out(me_alu_out),
    .me_rs2_data(me_true_rs2_data),
    .me_rd_addr(me_rd_addr),
    .me_rs2_addr(me_rs2_addr)
);



mux_2 MUX_WB_INSTANCE(
    .signal(forwardC),
    .a(me_rs2_data),
    .b(wb_rd_write_data),

    .out(me_true_rs2_data)
);

ram RAM_INSTANCE(
    .clk(clk),
    .rst(rst),

    .ram_addr(me_alu_out),
    .write_ram_data(me_true_rs2_data),
    .write_ram_flag(me_write_ram_flag),
    .read_ram_flag(me_read_ram_flag),

    .ram_out(me_ram_out),

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



// ********************************
//         me_wb 寄存器
// ********************************

me_wb ME_WB(
    .clk(clk),
    .rst(rst),

    .me_wb_aluOut_or_memOut(me_wb_aluOut_or_memOut),
    .me_write_reg_enable(me_write_reg_enable),
    .me_ram_out(me_ram_out),
    .me_alu_out(me_alu_out),
    .me_rd_addr(me_rd_addr),

    .wb_wb_aluOut_or_memOut(wb_wb_aluOut_or_memOut),
    .wb_write_reg_enable(wb_write_reg_enable),
    .wb_ram_out(wb_ram_out),
    .wb_alu_out(wb_alu_out),
    .wb_rd_addr(wb_rd_addr)
);

mux_2 MUX_WB(
    .signal(wb_wb_aluOut_or_memOut),
    .a(wb_alu_out),
    .b(wb_ram_out),

    .out(wb_rd_write_data)
);

endmodule
