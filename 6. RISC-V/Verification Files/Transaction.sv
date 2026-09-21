// -------------------------------------------------------------------------
// Transaction.sv
// Represents a single RISC-V Instruction
// UPDATED: With Control Flow Constraints
// -------------------------------------------------------------------------

`ifndef TRANSACTION_SV
`define TRANSACTION_SV

typedef enum bit [2:0] {R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE} instr_fmt_t;

typedef enum bit [5:0] {
    // R-Type
    ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU,
    // I-Type
    ADDI, ANDI, ORI, XORI, LB, LH, LW, LBU, LHU,
    // S-Type
    SB, SH, SW,
    // B-Type
    BEQ, BNE, BLT, BGE, BLTU, BGEU,
    // U-Type
    LUI, AUIPC,
    // J-Type
    JAL, JALR
} instr_name_t;

class transaction;

    rand instr_name_t instr_name;
    rand instr_fmt_t  instr_fmt;
    
    rand bit [4:0]  rs1, rs2, rd;
    rand bit [31:0] imm; 

    // ------------------------------------------------
    // Observation Fields (For Monitor)
    // ------------------------------------------------
    // The Monitor fills these. They don't need to be 'rand'.
    bit [31:0] pc_addr;      // The PC value seen on the bus
    bit [31:0] raw_instr;    // The machine code seen on the bus
    
    bit        mem_we;       // Write Enable seen on the bus
    bit [31:0] mem_addr;     // Address seen on the Data Bus
    bit [31:0] mem_wdata;    // Data written to memory
    bit [31:0] mem_rdata;    // (For Loads)
    
    // Optional: If you want to store the result for the scoreboard
    bit [31:0] result_val;


    // ------------------------------------------------
    // Constraints
    // ------------------------------------------------

    // 1. Format Mapping (Same as before)
    constraint c_fmt {
        if (instr_name inside {ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU})
            instr_fmt == R_TYPE;
        else if (instr_name inside {ADDI, ANDI, ORI, XORI, LB, LH, LW, LBU, LHU, JALR}) 
            instr_fmt == I_TYPE;
        else if (instr_name inside {SB, SH, SW})
            instr_fmt == S_TYPE;
        else if (instr_name inside {BEQ, BNE, BLT, BGE, BLTU, BGEU})
            instr_fmt == B_TYPE;
        else if (instr_name inside {LUI, AUIPC})
            instr_fmt == U_TYPE;
        else if (instr_name inside {JAL})
            instr_fmt == J_TYPE;
    }

    // 2. Control Flow Safety (THE NEW PART)
    // We restrict branches/jumps to small offsets so execution stays valid.
    constraint c_branch_jump_limits {
        if (instr_fmt == B_TYPE) {
            // Limit jump to +/- 8 instructions (32 bytes)
            imm inside {[-32:32]}; 
            
            // RISC-V branch offsets must be multiples of 2 (or 4)
            // Since we aren't using compressed instructions, let's enforce 4-byte alignment
            imm % 4 == 0;
            
            // Avoid infinite loops (branch to self, offset 0)
            imm != 0;
        }
        else if (instr_fmt == J_TYPE) {
            // Limit JAL to +/- 8 instructions
            imm inside {[-32:32]};
            imm % 4 == 0;
            imm != 0;
        }
    }

    // 3. General Immediate Validity
    constraint c_imm_valid {
        if (instr_fmt == I_TYPE) {
            imm inside {[-2048:2047]};
        }
        else if (instr_fmt == S_TYPE) {
            imm inside {[-2048:2047]};
        }
        // Note: B_TYPE and J_TYPE handled above
        else if (instr_fmt == U_TYPE) {
             imm[11:0] == 0; 
        }
    }

    // 4. Register Safety
    constraint c_no_x0_write {
        rd != 0; 
    }

    //5. Safety for mixed instructions
    constraint mixed_instr {
        instr_fmt dist {
            R_TYPE := 30,  // Arithmetic
            I_TYPE := 30,  // Immediate Arithmetic & Loads
            S_TYPE := 10,  // Stores
            B_TYPE := 15,  // Branches
            J_TYPE := 5,   // Jumps (JAL)
            U_TYPE := 10   // Upper Immediates
        };
    }
    
    //---------------------------------------------
    // Functions for instruction encoding
    //---------------------------------------------
    function bit [31:0] get_instr_code();
        bit [6:0] opcode;
        bit [2:0] funct3;
        bit [6:0] funct7;
        
        // Default values
        funct7 = 7'b0000000; 

        case (instr_name)
            // -----------------------------
            // R-TYPE
            // -----------------------------
            ADD:  begin opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; end
            SUB:  begin opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; end
            SLL:  begin opcode = 7'b0110011; funct3 = 3'b001; end
            SLT:  begin opcode = 7'b0110011; funct3 = 3'b010; end
            SLTU: begin opcode = 7'b0110011; funct3 = 3'b011; end
            XOR:  begin opcode = 7'b0110011; funct3 = 3'b100; end
            SRL:  begin opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0000000; end
            SRA:  begin opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0100000; end
            OR:   begin opcode = 7'b0110011; funct3 = 3'b110; end
            AND:  begin opcode = 7'b0110011; funct3 = 3'b111; end

            // -----------------------------
            // I-TYPE (Arithmetic)
            // -----------------------------
            ADDI: begin opcode = 7'b0010011; funct3 = 3'b000; end
            ANDI: begin opcode = 7'b0010011; funct3 = 3'b111; end
            ORI:  begin opcode = 7'b0010011; funct3 = 3'b110; end
            XORI: begin opcode = 7'b0010011; funct3 = 3'b100; end
            // Note: SLLI, SRLI, SRAI use special imms, usually require distinct handling
            // but fit in I-Type format if imm is constrained properly.

            // -----------------------------
            // I-TYPE (Jump)
            // -----------------------------
            JALR: begin opcode = 7'b1100111; funct3 = 3'b000; end

            // -----------------------------
            // I-TYPE (Loads)
            // -----------------------------
            LB:   begin opcode = 7'b0000011; funct3 = 3'b000; end
            LH:   begin opcode = 7'b0000011; funct3 = 3'b001; end
            LW:   begin opcode = 7'b0000011; funct3 = 3'b010; end
            LBU:  begin opcode = 7'b0000011; funct3 = 3'b100; end
            LHU:  begin opcode = 7'b0000011; funct3 = 3'b101; end

            // -----------------------------
            // S-TYPE (Stores)
            // -----------------------------
            SB:   begin opcode = 7'b0100011; funct3 = 3'b000; end
            SH:   begin opcode = 7'b0100011; funct3 = 3'b001; end
            SW:   begin opcode = 7'b0100011; funct3 = 3'b010; end

            // -----------------------------
            // B-TYPE (Branches)
            // -----------------------------
            BEQ:  begin opcode = 7'b1100011; funct3 = 3'b000; end
            BNE:  begin opcode = 7'b1100011; funct3 = 3'b001; end
            BLT:  begin opcode = 7'b1100011; funct3 = 3'b100; end
            BGE:  begin opcode = 7'b1100011; funct3 = 3'b101; end
            BLTU: begin opcode = 7'b1100011; funct3 = 3'b110; end
            BGEU: begin opcode = 7'b1100011; funct3 = 3'b111; end

            // -----------------------------
            // U-TYPE
            // -----------------------------
            LUI:   begin opcode = 7'b0110111; end
            AUIPC: begin opcode = 7'b0010111; end

            // -----------------------------
            // J-TYPE
            // -----------------------------
            JAL:  begin opcode = 7'b1101111; end
            
            default: begin opcode = 0; funct3 = 0; end 
        endcase

        case (instr_fmt)
            R_TYPE: return {funct7, rs2, rs1, funct3, rd, opcode};
            I_TYPE: return {imm[11:0], rs1, funct3, rd, opcode};
            S_TYPE: return {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
            B_TYPE: return {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
            U_TYPE: return {imm[31:12], rd, opcode};
            J_TYPE: return {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
            default: return 32'h0;
        endcase
    endfunction


    // ... display function ...
    function void display();
        begin
            $display("Instruction: %0s, Format: %0s, rs1: %0d, rs2: %0d, rd: %0d, imm: %0d", 
                 instr_name.name(), instr_fmt.name(), rs1, rs2, rd, imm);
        
            if (pc_addr != 0) begin
                $display("      [OBSERVED] PC:0x%h | MemAddr:0x%h | MemWrite:%0b", pc_addr, mem_addr, mem_we);
            end
        end
    endfunction

endclass

`endif // TRANSACTION_SV