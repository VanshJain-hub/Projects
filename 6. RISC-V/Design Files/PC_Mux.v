module PC_Mux(
    input [1:0]PCSrc,
    input [31:0] PC_Target, 
    input [31:0] PC_Plus_4,
    input [31:0] ALUResult,
    output reg [31:0] PC_Next
);

    always@(*) begin
        case (PCSrc)
            2'b00 : PC_Next = PC_Plus_4;
            2'b01 : PC_Next = PC_Target;
            2'b10 : PC_Next = ALUResult;
            default : PC_Next = PC_Plus_4;
        endcase
    end
    
endmodule