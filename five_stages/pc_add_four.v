module pc_add_four (
    input [31:0] pc,
    output [31:0] pc_add_4
);

assign pc_add_4 = pc + 4;

endmodule //pc_add_four