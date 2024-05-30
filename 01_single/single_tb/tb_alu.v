`include "../single_32/alu.v"
`timescale 1ns / 100ps 

module tb_alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [4:0]  op;

    wire [31:0] result;
    wire branch_enable;

    alu alu(
        .a(a),
        .b(b),
        .alu_opt(op),
        .out(result),
        .branch_enable(branch_enable)
        );

    initial begin
        // add
        a = 1;          b = 1;      op = 0; #20;
        // sub
        a = 9;         b = 2;     op = 1; #20;        
        // and
        a = 3'b101;     b = 3'b110; op = 2; #20;
        // or
        a = 3'b101;     b = 3'b110; op = 3; #20;
        // xor
        a = 3'b110;     b = 3'b010; op = 4; #20;
        // sll (Shift Left Logical)
        a = 1;          b = 3;      op = 5; #20;
        // srl (Shift Right Logical)
        a = 8;          b = 2;      op = 6; #20;
        // sra (Shift Right Arithmetic)
        a = -8;         b = 2;      op = 7; #20;
        // mul
        a = 6;          b = 5;      op = 8; #20;
        // mulh
        a = 32'h80000000;   b = 4;  op = 9; #20; // output will be ...0010 = 2
        // div
        a = 66;         b = 11;     op = 10; #20;
        // rem
        a = 62;         b = 3;      op = 11; #20;
        // slt (Set Less Than)
        a = -1;         b = 9;      op = 12; #20;
        // sltu (Set Less Than Unsigned)
        a = -1;         b = 9;      op = 13; #20;
    end

    initial begin
        $dumpfile("vcd/alu.vcd");
        $dumpvars(0, tb_alu);
    end
endmodule