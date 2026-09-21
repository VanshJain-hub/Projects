// -------------------------------------------------------------------------
// DirectedGenerator.sv
// Manually defines a specific sequence of instructions
// -------------------------------------------------------------------------
`include "Generator.sv"

class directed_generator extends generator;

    // 1. Constructor (Matches Parent)
    function new(mailbox #(transaction) gen2drv, int count);
        super.new(gen2drv, count);
    endfunction

    // 2. Override Run Task
    virtual task run();
        transaction tr;
        $display("[GEN] Starting DIRECTED Test Sequence...");

        // --- INSTRUCTION 1: ADDI x1, x0, 10 ---
        // Result: x1 should become 10 (0x0000000A)
        tr = new();
        tr.instr_name = ADDI; tr.instr_fmt = I_TYPE;
        tr.rd = 1; tr.rs1 = 0; tr.imm = 10;
        gen2drv.put(tr);
        $display("[GEN] Directed: ADDI x1, x0, 10");

        // --- INSTRUCTION 2: ADDI x2, x0, 20 ---
        // Result: x2 should become 20 (0x00000014)
        tr = new();
        tr.instr_name = ADDI; tr.instr_fmt = I_TYPE;
        tr.rd = 2; tr.rs1 = 0; tr.imm = 20;
        gen2drv.put(tr);
        $display("[GEN] Directed: ADDI x2, x0, 20");

        // --- INSTRUCTION 3: ADD x3, x1, x2 ---
        // Result: x3 = 10 + 20 = 30 (0x0000001E)
        tr = new();
        tr.instr_name = ADD; tr.instr_fmt = R_TYPE;
        tr.rd = 3; tr.rs1 = 1; tr.rs2 = 2;
        gen2drv.put(tr);
        $display("[GEN] Directed: ADD x3, x1, x2");

        // --- INSTRUCTION 4: SUB x4, x2, x1 ---
        // Result: x4 = 20 - 10 = 10 (0x0000000A)
        tr = new();
        tr.instr_name = SUB; tr.instr_fmt = R_TYPE;
        tr.rd = 4; tr.rs1 = 2; tr.rs2 = 1;
        gen2drv.put(tr);
        $display("[GEN] Directed: SUB x4, x2, x1");

        // Finish
        -> done;
    endtask

endclass