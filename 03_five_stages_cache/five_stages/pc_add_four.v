module pc_add_four (
    input [31:0] pc,
    output [31:0] pc_add_four
);

assign pc_add_four = pc + 4;

endmodule //pc_add_four