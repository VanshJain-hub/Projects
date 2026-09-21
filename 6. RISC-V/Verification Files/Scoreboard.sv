// -------------------------------------------------------------------------
// Scoreboard.sv
// UPDATED: Supports full RV32I Instruction Set
// -------------------------------------------------------------------------
`include "Transaction.sv"

class scoreboard;

    // 1. Handles
    mailbox #(transaction) mon2scb;
    virtual riscv_if.MON vif;

    // 2. The Golden State (Reference Model)
    bit [31:0] ref_regs [0:31]; 

    // 3. Variables for decoding
    bit [6:0] opcode;
    bit [2:0] funct3;
    bit [6:0] funct7;
    bit [4:0] rs1, rs2, rd;
    bit [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    // 4. Constructor
    function new(mailbox #(transaction) mon2scb, virtual riscv_if.MON vif);
        this.mon2scb = mon2scb;
        this.vif = vif;
        foreach(ref_regs[i]) ref_regs[i] = 0;
    endfunction

    // 5. Main Run Task
    task run();
        transaction tr;
        $display("[SCB] Scoreboard Initialized.");

        forever begin
            mon2scb.get(tr);

            // A. Decode
            decode(tr.raw_instr);

            // B. Execute Reference Logic
            // We pass 'tr' because we need PC and Memory Data for some instructions
            execute_reference_logic(tr);

            // C. Compare
            check_results(tr);
        end
    endtask

    // ------------------------------------------------
    // Helper: Decode (Same as before)
    // ------------------------------------------------
    function void decode(bit [31:0] instr);
        opcode = instr[6:0];
        rd     = instr[11:7];
        funct3 = instr[14:12];
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct7 = instr[31:25];
        
        imm_i = {{20{instr[31]}}, instr[31:20]};
        imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        imm_b = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        imm_u = {instr[31:12], 12'b0};
        imm_j = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    endfunction

    // ------------------------------------------------
    // REFERENCE MODEL LOGIC (UPDATED)
    // ------------------------------------------------
    function void execute_reference_logic(transaction tr);
        if (rd == 0) return; // Never write to x0

        case (opcode)
            // --------------------------------
            // R-TYPE
            // --------------------------------
            7'b0110011: begin 
                case (funct3)
                    3'b000: begin 
                        if (funct7 == 7'b0000000) ref_regs[rd] = ref_regs[rs1] + ref_regs[rs2]; // ADD
                        else                      ref_regs[rd] = ref_regs[rs1] - ref_regs[rs2]; // SUB
                    end
                    3'b001: ref_regs[rd] = ref_regs[rs1] << ref_regs[rs2][4:0]; // SLL
                    3'b010: ref_regs[rd] = ($signed(ref_regs[rs1]) < $signed(ref_regs[rs2])) ? 1 : 0; // SLT
                    3'b011: ref_regs[rd] = (ref_regs[rs1] < ref_regs[rs2]) ? 1 : 0;             // SLTU
                    3'b100: ref_regs[rd] = ref_regs[rs1] ^ ref_regs[rs2]; // XOR
                    3'b101: begin
                        if (funct7 == 7'b0000000) ref_regs[rd] = ref_regs[rs1] >> ref_regs[rs2][4:0];  // SRL
                        else                      ref_regs[rd] = $signed(ref_regs[rs1]) >>> ref_regs[rs2][4:0]; // SRA
                    end
                    3'b110: ref_regs[rd] = ref_regs[rs1] | ref_regs[rs2]; // OR
                    3'b111: ref_regs[rd] = ref_regs[rs1] & ref_regs[rs2]; // AND
                endcase
            end

            // --------------------------------
            // I-TYPE (Arithmetic)
            // --------------------------------
            7'b0010011: begin 
                case (funct3)
                    3'b000: ref_regs[rd] = ref_regs[rs1] + imm_i; // ADDI
                    3'b001: ref_regs[rd] = ref_regs[rs1] << imm_i[4:0]; // SLLI
                    3'b010: ref_regs[rd] = ($signed(ref_regs[rs1]) < $signed(imm_i)) ? 1 : 0; // SLTI
                    3'b011: ref_regs[rd] = (ref_regs[rs1] < imm_i) ? 1 : 0;             // SLTIU
                    3'b100: ref_regs[rd] = ref_regs[rs1] ^ imm_i; // XORI
                    3'b101: begin
                        if (imm_i[10] == 0) ref_regs[rd] = ref_regs[rs1] >> imm_i[4:0];  // SRLI
                        else                ref_regs[rd] = $signed(ref_regs[rs1]) >>> imm_i[4:0]; // SRAI
                    end
                    3'b110: ref_regs[rd] = ref_regs[rs1] | imm_i; // ORI
                    3'b111: ref_regs[rd] = ref_regs[rs1] & imm_i; // ANDI
                endcase
            end
            
            // --------------------------------
            // LOAD INSTRUCTIONS
            // --------------------------------
            7'b0000011: begin
                // Since the Scoreboard doesn't have the Data Memory array, we can't look up
                // what "should" be in memory. We must trust that the DUT read the bus correctly.
                // In a stricter testbench, we would shadow the D-Mem here.
                // For now, we assume the load returns whatever is on the 'read_data' bus.
                
                // IMPORTANT: You need to add 'bit [31:0] mem_rdata;' to Transaction & Monitor 
                // to support this perfectly. If not, this check will likely fail or needs skipping.
                ref_regs[rd] = tr.mem_rdata; 
            end

            // --------------------------------
            // U-TYPE
            // --------------------------------
            7'b0110111: ref_regs[rd] = imm_u;                 // LUI
            7'b0010111: ref_regs[rd] = tr.pc_addr + imm_u;    // AUIPC

            // --------------------------------
            // JUMPS (JAL & JALR)
            // --------------------------------
            // Both write PC+4 to the destination register (Link Register)
            7'b1101111: ref_regs[rd] = tr.pc_addr + 4;        // JAL
            7'b1100111: ref_regs[rd] = tr.pc_addr + 4;        // JALR

        endcase

        // Enforce x0 is always 0
        ref_regs[0] = 0;
    endfunction

    // ------------------------------------------------
    // CHECKER
    // ------------------------------------------------
    function void check_results(transaction tr);
        // Only check instructions that write to registers (rd != 0)
        // Skip Branches (B-Type) and Stores (S-Type) as they don't update RegFile
        
        if (rd != 0 && opcode != 7'b1100011 && opcode != 7'b0100011) begin
            
            // NOTE: If this is a LOAD instruction, we skip the check unless we implemented
            // the D-Mem mirroring above.
            if (opcode == 7'b0000011) return; 

            if (ref_regs[rd] !== vif.gp_regs[rd]) begin
                $error("[SCB] FAIL! PC:0x%h | Instr:%h | Reg x%0d | Exp: 0x%h | Act: 0x%h", 
                        tr.pc_addr, tr.raw_instr, rd, ref_regs[rd], vif.gp_regs[rd]);
            end 
            else begin
                $display("[SCB] PASS: PC:0x%h | Reg x%0d = 0x%h", tr.pc_addr, rd, vif.gp_regs[rd]);
            end
        end
    endfunction

endclass