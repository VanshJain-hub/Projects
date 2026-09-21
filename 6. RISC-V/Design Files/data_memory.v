module Data_Memory (
    input  [31:0] A,     
    input  [31:0] WD,    
    input         CLK,   
    input         WE,
    input [31:0] Instr,    
    output reg [31:0] RD    
);

    reg [31:0] mem [0:63];
    wire [2:0] funct3 = Instr[14:12];
    
    wire [31:0] word_data = mem[A[31:2]];
    wire [1:0] offset = A[1:0];
    
    //For Loading (Reading) Signed/Unsigned HalfWord and Byte operations as well
    always@(*) begin
        case(funct3)
            //LW - 32 bits
            3'b010 : RD = word_data; 

            //LB - 8 bits Signed
            3'b000 : begin
                case(offset)
                    2'b00 : RD = {{24{word_data[7]}}, word_data[7:0]};
                    2'b01 : RD = {{24{word_data[15]}}, word_data[15:8]};
                    2'b10 : RD = {{24{word_data[23]}}, word_data[23:16]};
                    2'b11 : RD = {{24{word_data[31]}}, word_data[31:24]};
                endcase
                end

            //LBU - 8 bits Unsigned
            3'b100 : begin
                case(offset)
                    2'b00 : RD = {24'b0, word_data[7:0]};
                    2'b01 : RD = {24'b0, word_data[15:8]};
                    2'b10 : RD = {24'b0, word_data[23:16]};
                    2'b11 : RD = {24'b0, word_data[31:24]};
                endcase
            end

            //LH - 16 bits Signed
            3'b001 : begin
                    case(offset[1])
                    1'b0 : RD = {{16{word_data[15]}}, word_data[15:0]};
                    1'b1 : RD = {{16{word_data[31]}}, word_data[31:16]};
                    endcase
                end

            //LHU - 16 bits Unsigned
            3'b101 : begin
                    case(offset[1])
                    1'b0 : RD = {16'b0, word_data[15:0]};
                    1'b1 : RD = {16'b0, word_data[31:16]};
                    endcase
                end

            default : RD = word_data;
        endcase
    end

    // Writing in the memory
    always @(posedge CLK) begin
        if (WE) begin
            case(funct3)
                //SW
                3'b010 : mem[A[31:2]] <= WD;

                //SB
                3'b000 : begin
                    case(offset)
                        2'b00 : mem[A[31:2]][7:0] <= WD[7:0];
                        2'b01 : mem[A[31:2]][15:8] <= WD[7:0];
                        2'b10 : mem[A[31:2]][23:16] <= WD[7:0];
                        2'b11 : mem[A[31:2]][31:24] <= WD[7:0];
                    endcase
                end

                //SH
                3'b001 : begin
                    case(offset[1])
                        1'b0 : mem[A[31:2]][15:0] <= WD[15:0];
                        1'b1 : mem[A[31:2]][31:16] <= WD[15:0];
                    endcase
                end
            endcase
        end
end

endmodule
