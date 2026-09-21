// -------------------------------------------------------------------------
// Subscriber.sv
// Captures Functional Coverage
// -------------------------------------------------------------------------
`include "Transaction.sv"

class subscriber;
    
    // 1. Handles
    mailbox #(transaction) mbx;
    transaction tr;
    
    // 2. Covergroup
    covergroup riscv_cov;
        
        // Track Format (R, I, S, B, U, J)
        cp_format: coverpoint tr.instr_fmt;
        
        // Track Instruction Names (ADD, SUB, LW, etc.)
        cp_instr:  coverpoint tr.instr_name;
        
        // Track Destination Registers (x0 to x31)
        cp_rd:     coverpoint tr.rd {
            bins zero     = {0};
            bins lower    = {[1:15]};
            bins upper    = {[16:31]};
        }
        
        // Cross Coverage (e.g., Did we test R-Type on Lower Registers?)
        cross cp_format, cp_rd;
        
    endgroup

    // 3. Constructor
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
        riscv_cov = new(); // Create the covergroup instance
    endfunction

    // 4. Run Task
    task run();
        forever begin
            mbx.get(tr);        // Wait for transaction
            riscv_cov.sample(); // Sample it
        end
    endtask
    
    // 5. Console Report (Useful for quick checks)
    function void print_report();
        $display("\n[COV] =========================================");
        $display("[COV]       FUNCTIONAL COVERAGE REPORT");
        $display("[COV] =========================================");
        $display("[COV] Total Coverage:      %0.2f%%", riscv_cov.get_coverage());
        $display("[COV] Instruction Cov:     %0.2f%%", riscv_cov.cp_instr.get_coverage());
        $display("[COV] Register (rd) Cov:   %0.2f%%", riscv_cov.cp_rd.get_coverage());
        $display("[COV] =========================================\n");
    endfunction

endclass