module ALU_Decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7b5,
    input opb5,
    output reg [3:0] ALUControl
);

    always@(ALUOp or funct3 or funct7b5 or opb5) 
    begin
        case (ALUOp)
            2'b00 : ALUControl = 4'b0000; //Memory Access: lw, sw
            2'b01 : ALUControl = 4'b0001; //Branching: beq & AUIPC
            2'b10 : begin //R-Type and I-Type Arithmetic
                case (funct3) //This is for exactly which type of instruction (add, sub, and, addi, etc)
                    3'b000 : begin
                        if(funct7b5 == 1'b1 && opb5 == 1'b1) ALUControl = 4'b0001; //SUB
                        else ALUControl = 4'b0000; //ADD
                    end
                    3'b001 : ALUControl = 4'b1010; //SLL
                    3'b010 : ALUControl = 4'b0101; //SLT
                    3'b011 : ALUControl = 4'b0110; //SLTU
                    3'b100 : ALUControl = 4'b0100; //XOR
                    3'b101 : begin
                        if(funct7b5 == 1'b0) ALUControl = 4'b1011; //SRL
                        else ALUControl = 4'b1100; //SRA
                    end
                    3'b110 : ALUControl = 4'b0011; //OR
                    3'b111 : ALUControl = 4'b0010; //AND
                    default : ALUControl = 4'bxxxx;
                endcase
            end
            2'b11: ALUControl = 4'b1001; //LUI

            default : ALUControl = 4'bxxxx;
        endcase
    end
    
endmodule