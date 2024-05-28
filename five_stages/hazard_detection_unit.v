module hazard_detection_unit(
    input [2: 0] ex_read_ram_flag,
    input [4: 0] ex_rd_addr, id_rs1_addr, id_rs2_addr,

    output reg pause
);

always @(*) begin
    pause = 1'b0;
    if((ex_read_ram_flag != 3'b000) && ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
        pause = 1'b1;
    end
end

endmodule