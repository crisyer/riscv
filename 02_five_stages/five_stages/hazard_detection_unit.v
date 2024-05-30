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
//但load需要至少在wb阶段,才能把数据从ram中读出来,所以至少得让 load的分支流水线继续走下去,
//后续的位于id阶段/并且依赖load这条线的流水线暂停: 
//      1. pc暂停更新,2.一致保持在id阶段(ex一直到最后阶段清空)
endmodule