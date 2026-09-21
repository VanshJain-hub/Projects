module PC_Target(
    input [31:0] PC,
    input [31:0] ImmExt,
    output [31:0] PCTarget
);

    assign PCTarget = PC + ImmExt;
    
endmodule