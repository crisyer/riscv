module alu(
    input[4: 0] alu_opt,
    input [31: 0] a, b,

    output reg [31: 0] alu_out, 
    output reg branch_enable
);
always @(*) begin
    branch_enable = 0;
    alu_out = 32'b0;
    case (alu_opt)
        5'b00000: alu_out = a + b;
        5'b00001: alu_out = a - b;
        5'b00010: alu_out = a & b;
        5'b00011: alu_out = a | b;
        5'b00100: alu_out = a ^ b;
        5'b00101: alu_out = a << b;
        5'b00110: alu_out = ($signed(a) < ($signed(b))) ? 32'b1 : 32'b0;
        5'b00111: alu_out = (a < b) ? 32'b1 : 32'b0;
        5'b01000: alu_out = a >> b;
        5'b01001: alu_out = b[11] == 1?  a << b[4:0] : ($signed(a)) >>> b[4:0];
        5'b01010: begin 
            alu_out = a + b;
            // alu_out = alu_out>>2;
        end
        5'b01011: branch_enable = (a == b) ? 1'b1 : 1'b0;
        5'b01100: branch_enable = (a != b) ? 1'b1 : 1'b0;
        5'b01101: branch_enable = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0;
        5'b01110: branch_enable = ($signed(a) >= $signed(b)) ? 1'b1 : 1'b0;
        5'b01111: branch_enable = (a < b) ? 1'b1: 1'b0;
        5'b10000: branch_enable = (a >= b) ? 1'b1: 1'b0;
        5'b10001: alu_out = b ;
        default: alu_out = 32'b0;
    endcase
end
endmodule