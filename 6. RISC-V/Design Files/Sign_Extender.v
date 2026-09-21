module Sign_Extender(
    input [31:0] Instr,
    input [2:0] ImmSrc,
    output reg [31:0] ImmExt
);

    always @(*) begin
        case (ImmSrc)
            // I-Type: 12-bit signed
            3'b000 : ImmExt = {{20{Instr[31]}}, Instr[31:20]};
            
            // S-Type: 12-bit signed (Store)
            3'b001 : ImmExt = {{20{Instr[31]}}, Instr[31:25], Instr[11:7]};
            
            // B-Type: 13-bit signed (Branch)
            // Note: 20 repetitions cover the 19 sign-ext bits + the 1 MSB of immediate
            3'b010 : ImmExt = {{20{Instr[31]}}, Instr[7], Instr[30:25], Instr[11:8], 1'b0};
            
            // J-Type: 21-bit signed (Jump)
            // Note: 12 repetitions cover the 11 sign-ext bits + the 1 MSB of immediate
            3'b011 : ImmExt = {{12{Instr[31]}}, Instr[19:12], Instr[20], Instr[30:21], 1'b0};
            
            // U-Type: 20-bit upper immediate (LUI/AUIPC)
            3'b100 : ImmExt = {Instr[31:12], 12'b0};
            
            default : ImmExt = 32'bx;
        endcase
    end
endmodule