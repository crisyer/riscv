module forward_unit(
    input me_write_reg_enable, wb_write_reg_enable,
    input [4: 0] me_rd_addr, wb_rd_addr,
    input [4: 0] ex_rs1_addr, ex_rs2_addr,
    input [4: 0] me_rs2_addr,

    output reg [1: 0] ex_forwardA, ex_forwardB,
    output reg me_forwardC
);

always @(*) begin
    ex_forwardA = 2'b00;
    ex_forwardB = 2'b00;
    me_forwardC = 1'b0;

    if(wb_write_reg_enable && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs1_addr)) begin
        ex_forwardA = 2'b10;
    end

    if(wb_write_reg_enable && (wb_rd_addr != 5'd0) && (wb_rd_addr == ex_rs2_addr)) begin
        ex_forwardB = 2'b10;
    end

    if(me_write_reg_enable && (me_rd_addr != 5'd0) && (me_rd_addr == ex_rs1_addr)) begin
        ex_forwardA = 2'b01;
    end

    if(me_write_reg_enable && (me_rd_addr != 5'd0) && (me_rd_addr == ex_rs2_addr)) begin
        ex_forwardB = 2'b01;
    end

    // lw, sw数据冒险
    if(wb_write_reg_enable && (wb_rd_addr != 5'd0) && (wb_rd_addr == me_rs2_addr)) begin
        me_forwardC = 1'b1;
    end
end

endmodule