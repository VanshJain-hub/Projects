module Instruction_Memory (
    input  [31:0] A,    // Address input (32-bit)
    output [31:0] RD    // Data output (32-bit)
);

    reg [31:0] mem [0:63];
    initial begin
        // mem[0] = 32'h000000B3;  
        // mem[1] = 32'h00000233;  
        // mem[2] = 32'h00A08113;  
        // mem[3] = 32'h000081B3;  
        // mem[4] = 32'h00218863;  
        // mem[5] = 32'h00418233;  
        // mem[6] = 32'h00118193;
        // mem[7] = 32'hfe000ae3;
        // mem[8] = 32'h000200b3;
        // mem[9] = 32'h00a0a023;
        // mem[10] = 32'h0000a083;      
        $readmemh("test_prog_FULL6.hex", mem);
        // mem[0] = 32'h123450B7; // LUI x1, 0x12345
        // mem[1] = 32'hDEADB137; // LUI x2, 0xDEADB
        // mem[2] = 32'h00001197; // AUIPC x3, 1
        // mem[3] = 32'h00002217; // AUIPC x4, 2
        // mem[4] = 32'h003082B3; // ADD x5, x1, x3
    end  

    assign RD = mem[A[31:2]];

endmodule