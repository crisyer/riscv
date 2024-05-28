module next_pc(
    input branch_enable,
    input [31: 0] pc, 
    input [31:0] pc_add_imm_32, 
    input [31:0] rs1_data_add_imm_32_for_pc,
    input [31:0] pc_add_4,

    input rst, clk,
    input [1: 0] pc_condition,

    output reg [31: 0] next_pc, 
    output reg flush
  );
  always @(*)
  begin
    case ({pc_condition,branch_enable}) 
    // 之前顺序执行的情况,没有flush.
      //normal
      3'b000 :
      begin
        next_pc <= pc_add_4;
        flush <= 0;
      end
      //branch not staisfied. continue + 4
      3'b010 :
      begin
        next_pc <= pc_add_4;
        flush <= 0;
      end

      //branch staisfied.
      3'b011 :
      begin
        next_pc <= pc_add_imm_32;
        flush <= 1;
      end

      // jal
      3'b100 :
      begin
        next_pc <= pc_add_imm_32;
        flush <= 1;
      end
      // jalr
      3'b110 :
      begin
        next_pc <= rs1_data_add_imm_32_for_pc;
        flush <= 1;
      end
      default :
      begin
        next_pc <= pc_add_4;
        flush <= 0;
      end
    endcase
  end
endmodule
