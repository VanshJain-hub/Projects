module controlpath(
    input Zero, Carry, Referee,
    input [31:0] Instr, 
    output MemWrite, RegWrite, ALUSrc, RegSrc, Branch, Jump, JumpReg,
    output [3:0] ALUControl,
    output [1:0] ResultSrc, PCSrc,
    output [2:0] ImmSrc //ALUOp 
);

    //ALU_Decoder: output: ALUControl 
    //Main Decoder: output: ALUSrc, MemWrite, 
    //Not Used: Main Decoder: Jump, Branch

    wire [1:0] ALUOp; //From Main Decoder to ALU_Decoder
    wire WE;
    //funct3: Instr[14:12]
    //funct7b5: Instr[30]
    //opb5: Instr[4]
    
    Main_Decoder MD1(.op(Instr[6:0]), .RegWrite(RegWrite), .ImmSrc(ImmSrc), .ALUSrc(ALUSrc), .MemWrite(MemWrite), .ResultSrc(ResultSrc), .Branch(Branch), .ALUOp(ALUOp), .Jump(Jump), .JumpReg(JumpReg));
    //MemWrite going to DataMemory
    assign WE = MemWrite;

    //Assigning PCSrc 
    // 2'b10 = JALR (ALU Result)
    // 2'b01 = Branch or JAL (PC Target)
    // 2'b00 = Next Instruction (PC + 4)
    wire BranchTaken;
    reg ConditionsMet;

    wire [2:0] funct3 = Instr[14:12];

    always@(*) begin
        case(funct3)
            3'b000 : ConditionsMet = Zero; //BEQ
            3'b001 : ConditionsMet = ~Zero; //BNE
            3'b100 : ConditionsMet = Referee; //BLT
            3'b101 : ConditionsMet = ~Referee; //BGE
            3'b110 : ConditionsMet = ~Carry; //BLTU
            3'b111 : ConditionsMet = Carry; //BGEU
            default : ConditionsMet = 1'b0;
        endcase
    end

    assign BranchTaken = (Branch & ConditionsMet) | Jump;
    assign PCSrc = (JumpReg) ? 2'b10 : (BranchTaken) ? 2'b01 : 2'b00;

    ALU_Decoder AD1(.ALUOp(ALUOp), .funct3(Instr[14:12]), .funct7b5(Instr[30]), .opb5(Instr[5]), .ALUControl(ALUControl));

    
    
endmodule