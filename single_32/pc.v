module pc(
    input rst, clk,
    input [31: 0] next_pc,

    output reg [31: 0] pc,
    output [31: 0] pc_rom_addr
);

always @(posedge clk) begin
    if(rst) pc = 32'd0; 
    // 这里是rom\ram分离的,所以复位直接到第一条指令,或者说,rom的第一地址
    // 如果没有分数据和指令存储器,那么pc将复位到数据区域.
    else pc <= next_pc;
end

always @(posedge rst) begin
    pc = 0;
end

assign pc_rom_addr = pc>>2;

endmodule