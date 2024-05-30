module if_id (
    input clk, rst,pause,flush,

    input [31:0] if_pc,
    input [31:0] if_instr,
    input pc_from_rom_ready,

    output reg [31:0] id_pc,
    output reg [31:0] id_instr
  );

  always @(posedge clk )
  begin
    if (rst || flush)
    begin
        id_pc <= 0;
        id_instr <= 32'h00000013;
    end
    else if( pc_from_rom_ready)
    begin
        id_pc <= if_pc;
        id_instr <= if_instr;
    end
    else begin
      id_instr <= 32'h00000013;
    end
  end

endmodule //if_id
