// -------------------------------------------------------------------------
// riscv_if.sv
// The physical interface connecting Testbench to the RISC-V Processor
// -------------------------------------------------------------------------

interface riscv_if (input logic clk, input logic reset);

    // ------------------------------------------------
    // 1. Instruction Memory Interface
    // ------------------------------------------------
    // The processor sends PC, we (TB) send back the Instruction
    logic [31:0] pc;          // From DUT (PC Output)
    logic [31:0] instr;       // To DUT (Instruction Input)

    // ------------------------------------------------
    // 2. Data Memory Interface
    // ------------------------------------------------
    // The processor sends Address/Data, we (TB) send back Read Data
    logic        mem_write;   // From DUT (Write Enable)
    logic        mem_read;    // From DUT (Read Enable)
    logic [31:0] data_addr;   // From DUT (Address)
    logic [31:0] write_data;  // From DUT (Data to write)
    logic [31:0] read_data;   // To DUT (Data read from memory)

    // ------------------------------------------------
    // 3. Whitebox / Debug Signals (Monitor Only)
    // ------------------------------------------------
    // These signals do not exist on the real chip pins, but we 
    // hook them up to check internal state as per your request.
    
    // Flags
    logic zero;
    logic carry;
    logic negative;
    logic overflow; // "Referee"

    // Register File Inspection
    // We create a copy of the 32 registers here to observe them
    logic [31:0] gp_regs [0:31]; 

    // ------------------------------------------------
    // 4. Modports (Direction specific views)
    // ------------------------------------------------

    // INSTRUCTION BFM (Driver): Acts as the Instruction Memory
    // It sees the PC (input) and provides the Instruction (output)
    modport INSTR_BFM (
        input  pc,
        output instr,
        input  clk,
        input  reset
    );

    // DATA SLAVE BFM (Driver): Acts as the Data Memory
    // It sees the Address/WriteData (inputs) and provides ReadData (output)
    modport DATA_BFM (
        input  mem_write,
        input  mem_read,
        input  data_addr,
        input  write_data,
        output read_data,
        input  clk,
        input  reset
    );

    // MONITOR: Observes EVERYTHING
    modport MON (
        input clk,
        input reset,
        input pc,
        input instr,
        input mem_write,
        input mem_read,
        input data_addr,
        input write_data,
        input read_data,
        // Whitebox inputs
        input zero,
        input carry,
        input negative,
        input overflow,
        input gp_regs
    );

endinterface