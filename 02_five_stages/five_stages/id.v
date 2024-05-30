module id (
    input [31:0]instr,

    output [6:0] opcode,
    output [2: 0] func3,
    output [6: 0] func7,
    output [4: 0] rd_addr,
    output [4: 0] rs1_addr,
    output [4: 0] rs2_addr
  );

  assign  opcode  = instr[6:0];
  assign  rs1_addr = instr[19:15];
  assign  rs2_addr = instr[24:20];
  assign  rd_addr  = instr[11:7];
  assign  func3  = instr[14:12];
  assign  func7  = instr[31:25];

endmodule //encode
