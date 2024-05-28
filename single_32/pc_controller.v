module pc_controller(
    input branch_enable,
    input [31: 0] pc, 
    input [31:0] imm_32, rs1_data,
    input rst, clk,
    input [1: 0] pc_condition,

    output reg [31: 0] next_pc
);
always @(*) begin
    case ({pc_condition,branch_enable})
        //normal
        3'b000 : next_pc <= pc + 32'd4;  

        //branch not staisfied. continue + 4
        3'b010 : next_pc <= pc + 32'd4;  

        //branch staisfied. 
        3'b011 : next_pc <= pc + imm_32;  

        // jal 
        3'b100 : next_pc <= pc + imm_32;  

        // jalr
        3'b110 : next_pc <= imm_32 + rs1_data;  
        default : next_pc <= pc + 32'd4;
    endcase
end
endmodule