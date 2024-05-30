module pc_add_four (
    input clk,
    input [31:0] pc,
    input pc_from_rom_ready,
    output reg [31:0] pc_add_four
  );

  always @(posedge clk)
  begin
    if (pc_from_rom_ready)
    begin
      pc_add_four <= pc + 4;
    end
    else
      pc_add_four <= pc_add_four;
  end

endmodule //pc_add_four
