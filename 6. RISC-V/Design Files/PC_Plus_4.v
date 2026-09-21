module PC_Plus_4(
    input [31:0] PC,
    output [31:0] PCPlus4
);
    integer p4 = 4;
    assign PCPlus4 = PC + p4;

endmodule