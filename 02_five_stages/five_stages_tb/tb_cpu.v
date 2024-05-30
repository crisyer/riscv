`include "../five_stages/cpu.v"
`timescale 1ns / 100ps 

module tb_cpu;
    reg clk = 1;
    input rst;
    
    cpu cpu_INSTANCE(
        .clk(clk),
        .rst(rst)
    );

    initial begin
        cpu_INSTANCE.PC_INSTANCE.pc<=32'd0;
    end

    integer i;
    initial begin
        for( i=0; i<128; i=i+1) begin
            clk=1; #20; clk=0; #20;
        end
    end

    initial begin
        $dumpfile("vcd/cpu.vcd");
        $dumpvars(0, tb_cpu);
    end
    // 0000 0000 0001 0011 0000 0011 0001 0011
    // 
endmodule