module hazard_detection_unit(
    input [2: 0] ex_load_ram_flag,
    input [4: 0] ex_rd_addr, id_rs1_addr, id_rs2_addr,

    output reg pause
);

always @(*) begin
    pause = 1'b0;
    if((ex_load_ram_flag != 3'b000) && ((ex_rd_addr == id_rs1_addr) || (ex_rd_addr == id_rs2_addr))) begin
        pause = 1'b1;
    end
end
//load会将数据从内存读取到寄存器中。
//此时,如果后续指令需要使用这个刚刚读取到寄存器的数据,就会存在数据相关性。
endmodule