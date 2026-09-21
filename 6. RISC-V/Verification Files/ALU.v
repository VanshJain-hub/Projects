module ALU(
    input  [31:0] A, B,
    input  [3:0]  control,
    output reg [31:0] result,
    //output reg Overflow, Negative,
    output reg Zero, Carry, Referee
);

    reg [32:0] temp;  
    reg Overflow, Negative;

    always @(*) begin
        result   = 32'b0;
        temp     = 33'b0;
        Zero     = 0;
        Overflow = 0;
        Carry    = 0;
        Negative = 0;

        case(control)
            4'b0000: begin  //ADD
                temp   = {1'b0, A} + {1'b0, B};
                result = temp[31:0];
                Carry  = temp[32];
                Overflow = ((~A[31] & ~B[31] & result[31]) |
                            ( A[31] &  B[31] & ~result[31]));
            end 

            4'b0001: begin  //SUB
                temp   = {1'b0, A} + {1'b0, ~B} + 1'b1; 
                result = temp[31:0];
                Carry  = temp[32]; 
                Overflow = (( A[31] & ~B[31] & ~result[31]) |
                            (~A[31] &  B[31] &  result[31]));
            end

            4'b0010: result = A & B;
            4'b0011: result = A | B;
            4'b0100: result = A ^ B;
            4'b0101: result = {31'b0, ($signed(A) < $signed(B))};
            4'b0110: result = {31'b0, (A < B)};
            4'b0111: result = {A[31:12],12'b0};
            4'b1000: result = A + {B[31:12],12'b0}; //No Need
            4'b1001: result = {B[31:12],12'b0};
            4'b1010: result = A << B[4:0];
            4'b1011: result = A >> B[4:0]; 
            4'b1100: result = $signed(A) >>> B[4:0];

            default: result = 32'b0;
        endcase

        Zero     = (result == 32'b0);
        Negative = result[31];
        Referee = Negative ^ Overflow;
    end

endmodule
