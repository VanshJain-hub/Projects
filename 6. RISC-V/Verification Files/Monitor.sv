// -------------------------------------------------------------------------
// Monitor.sv
// Observer: Captures Bus Activity and Whitebox signals
// -------------------------------------------------------------------------
`include "Transaction.sv"

class monitor;
    
    // 1. Handles
    virtual riscv_if.MON vif;       // Virtual Interface (Monitor Modport)
    mailbox #(transaction) mon2scb; // Mailbox to Scoreboard
    mailbox #(transaction) mon2cov; //Mailbox to Subscriber for coverage

    // 2. Constructor
    function new(virtual riscv_if.MON vif, mailbox #(transaction) mon2scb, mailbox #(transaction) mon2cov);
        this.vif = vif;
        this.mon2scb = mon2scb;
        this.mon2cov = mon2cov;
    endfunction

    // 3. Main Run Task
    task run();
        $display("[MON] Monitor Initialized.");
        
        forever begin
            // Sample on the negative edge or just after posedge to ensure stability
            // (Using posedge is standard, but we capture the values sampled at that edge)
            @(posedge vif.clk);

            if (!vif.reset) begin
                // Create a container for this cycle's data
                transaction tr = new();
                
                // ------------------------------------
                // A. Capture Standard Interface Signals
                // ------------------------------------
                tr.pc_addr   = vif.pc;
                tr.raw_instr = vif.instr;
                
                // Capture Memory Bus (Load/Store activity)
                tr.mem_we    = vif.mem_write;
                tr.mem_addr  = vif.data_addr;
                tr.mem_wdata = vif.write_data;
                tr.mem_rdata = vif.read_data;

                // ------------------------------------
                // B. Capture Whitebox Signals (Optional but helpful)
                // ------------------------------------
                // In a real advanced Monitor, we would also sample the Register File
                // output here to see exactly what was written to 'rd'.
                // Since we don't have a direct "WriteBack Data" signal on the interface
                // in our previous step (only the full array), we will rely on the 
                // Scoreboard to check the full array, or we could add:
                // tr.wb_data = vif.gp_regs[parsed_rd]; 
                
                // ------------------------------------
                // C. Filter Bubbles/NOPs
                // ------------------------------------
                // If the processor is stalling or resetting, we might see 0x0 or NOP.
                // We typically only send "valid" instructions to the Scoreboard.
                if (tr.raw_instr !== 32'h00000000 && tr.raw_instr !== 32'hxxxxxxxx) begin
                    
                    // Send to Scoreboard
                    mon2scb.put(tr);
                    mon2cov.put(tr); 
                    
                    // Optional Debug
                    // $display("[MON] Captured PC:0x%0h | Instr:0x%0h", tr.pc_addr, tr.raw_instr);
                end
            end
        end
    endtask

endclass