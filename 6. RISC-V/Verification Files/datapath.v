module datapath(
    input RegWrite, ALUSrc, RegSrc, 
    input [1:0] ResultSrc, PCSrc,
    input [2:0] ImmSrc,
    input [3:0] ALUControl,
    input clk, reset,
    input [31:0] RD, //Read Data from DataMem
    input [31:0] Instr,
    output Zero, Carry, Referee, 
    output [31:0] PC,
    output [31:0] WD, ALUResult
);

    wire [31:0] PCPlus4, PCTarget, ImmExt, PC_Next;//, ALUResult;
    wire [31:0] RD1, RD2;
    wire [31:0] B;
    wire [31:0] Result;


    //PC Next to the Instr File
    //Instrfile: Instruction from the file 
    //From Data Memory: o/p: Write Data, ALUResult, i/p: Read Data, 
    //clk, reset signals
    //.a(A): a-> DUT, A-> Current Design
    //Files: PC_Next, PC_Target, PC_Plus_4, RegFiles, ImmOffsetGen, ALU, ALUMux

    //Creating PC Next output. 
    //Input is PC, output is PC_Next.
    PC_Plus_4 P1(.PC(PC), .PCPlus4(PCPlus4));
    PC_Target P2(.PC(PC), .ImmExt(ImmExt), .PCTarget(PCTarget));
    PC_Mux P3(.PCSrc(PCSrc), .PC_Target(PCTarget), .PC_Plus_4(PCPlus4), .PC_Next(PC_Next), .ALUResult(ALUResult));
    Sign_Extender SE(.Instr(Instr), .ImmSrc(ImmSrc), .ImmExt(ImmExt));

    PC_Reg PC1(.PCNext(PC_Next), .clk(clk), .reset(reset), .PC(PC));

    //Instruction_Memory input RD
    
    //Data Memory: Inputs: ReadData | Outputs: WriteData, DataAddress(basically, ALUResult here)
    //RD2 data is going to the Write Data
    assign WD = RD2;

    //Register File: (WD3 is the ResultMux output, which is 'Result')
    Register_File RF(.RA1(Instr[19:15]), .RA2(Instr[24:20]), .WA3(Instr[11:7]), .WD3(Result), .WE3(RegWrite), .CLK(clk), 
    .RD1(RD1), .RD2(RD2));

    //ALU_Mux
    ALU_Mux ALM(.WD(RD2), .ImmExt(ImmExt), .ALUSrc(ALUSrc), .B(B));

    //ALU
    ALU AR(.A(RD1), .B(B), .control(ALUControl), .result(ALUResult), .Zero(Zero), .Carry(Carry), .Referee(Referee));
    
    //ResultMux
    Result_Mux RM(.ALUResult(ALUResult), .ReadData(RD), .PC_Plus_4(PCPlus4), .PC_Target(PCTarget), .ResultSrc(ResultSrc), .Result(Result));


endmodule