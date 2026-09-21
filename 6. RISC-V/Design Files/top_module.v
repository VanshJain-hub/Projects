module top_module(
    input reset, clk,
    output [31:0] display_data
);
    wire Zero, Carry, Referee; 
    wire MemWrite, RegWrite, ALUSrc, RegSrc;
    wire [1:0] ResultSrc, PCSrc;
    wire [2:0] ImmSrc;
    wire [3:0] ALUControl;

    wire [31:0] PC, Instr, DataAddr, WriteData, ReadData;

    wire Branch, Jump, JumpReg;

    //Instantiation Modules: datapath, controlpath, instruction_memory, data_memory

    datapath DP1(.RegWrite(RegWrite), .ALUSrc(ALUSrc), .PCSrc(PCSrc), .RegSrc(RegSrc), .ImmSrc(ImmSrc), 
    .ResultSrc(ResultSrc), .ALUControl(ALUControl), .clk(clk), .reset(reset), .RD(ReadData), .Instr(Instr), 
    .Zero(Zero), .Carry(Carry), .Referee(Referee), .PC(PC), .WD(WriteData), 
    .ALUResult(DataAddr), .display_data(display_data));
  
    controlpath CP1(.Zero(Zero), .Carry(Carry), .Referee(Referee), .Instr(Instr), .MemWrite(MemWrite), .RegWrite(RegWrite), .ALUSrc(ALUSrc), .PCSrc(PCSrc), .RegSrc(RegSrc), .ALUControl(ALUControl), .ResultSrc(ResultSrc), .ImmSrc(ImmSrc), .Branch(Branch), .Jump(Jump), .JumpReg(JumpReg));

    Instruction_Memory IM1(.A(PC), .RD(Instr));

    Data_Memory DM1(.A(DataAddr), .WD(WriteData), .CLK(clk), .WE(MemWrite), .RD(ReadData), .Instr(Instr));

endmodule