module ALU_Mux(
    input [31:0] WD,
    input [31:0] ImmExt,
    input ALUSrc,
    output reg [31:0] B
);

    always@(*) begin
        case (ALUSrc)
            1'b0 : B = WD;
            1'b1 : B = ImmExt;
        endcase
    end
    
endmodule