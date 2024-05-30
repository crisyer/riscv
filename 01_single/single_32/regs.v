module regs(
    input  clk, rst,
    input [4:0]  rs1_addr, rs2_addr, rd_addr,
    input  [31:0] writ_data,
    input  write_reg_enable, 

    output [31:0] rs1_data, 
    output [31:0] rs2_data,

    output [31:0]  reg_1,
    output [31:0]  reg_2,
    output [31:0]  reg_3,
    output [31:0]  reg_4,
    output [31:0]  reg_5,
    output [31:0]  reg_6,
    output [31:0]  reg_7,
    output [31:0]  reg_8,
    output [31:0]  reg_9,
    output [31:0]  reg_10,
    output [31:0]  reg_11,
    output [31:0]  reg_12,
    output [31:0]  reg_13,
    output [31:0]  reg_14,
    output [31:0]  reg_15,
    output [31:0]  reg_0
);
reg [31:0] regFile[31:0]; // 32个32位寄存器
    assign reg_0=regFile[0];
    assign reg_1=regFile[1];
    assign reg_2=regFile[2];
    assign reg_3=regFile[3];
    assign reg_4=regFile[4];
    assign reg_5=regFile[5];
    assign reg_6=regFile[6];
    assign reg_7=regFile[7];
    assign reg_8=regFile[8];
    assign reg_9=regFile[9];
    assign reg_10=regFile[10];
    assign reg_11=regFile[11];
    assign reg_12=regFile[12];
    assign reg_13=regFile[13];
    assign reg_14=regFile[14];
    assign reg_15=regFile[15];

always @(posedge clk or posedge rst) begin
    if (write_reg_enable) begin
        regFile[rd_addr] <= writ_data;
    end
end

assign rs1_data = rs1_addr == 5'd0 ? 32'd0 : regFile[rs1_addr];
assign rs2_data = rs2_addr == 5'd0 ? 32'd0 : regFile[rs2_addr];

endmodule
