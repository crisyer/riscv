module me_wb (
    input clk, rst,

    input me_wb_aluOut_or_memOut,
    input me_write_reg_enable,
    input [31:0] me_ram_out,
    input [31:0] me_alu_out,
    input [4:0] me_rd_addr,

    output reg wb_wb_aluOut_or_memOut,
    output reg wb_write_reg_enable,
    output reg [31:0] wb_ram_out,
    output reg [31: 0] wb_alu_out,
    output reg [4: 0] wb_rd_addr
  );

  always @(posedge clk)
  begin
    if (rst)
    begin
      wb_wb_aluOut_or_memOut <= 0;
      wb_write_reg_enable <= 1'b1;
      wb_ram_out <= 0;
      wb_alu_out <= 0;
      wb_rd_addr <= 0;
    end
    else
    begin
      wb_wb_aluOut_or_memOut <= me_wb_aluOut_or_memOut;
      wb_write_reg_enable <= me_write_reg_enable;
      wb_ram_out <= me_ram_out;
      wb_alu_out <= me_alu_out;
      wb_rd_addr <= me_rd_addr;
    end
  end

endmodule //me_wb