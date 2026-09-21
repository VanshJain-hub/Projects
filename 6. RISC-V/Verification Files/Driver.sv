// -------------------------------------------------------------------------
// Driver.sv (Instruction Memory BFM)
// 1. Loads the program from Generator into local memory
// 2. Responds to the Processor's PC requests
// -------------------------------------------------------------------------
`include "Transaction.sv"

class driver;
    
    // 1. Handles
    virtual riscv_if.INSTR_BFM vif;   // Virtual Interface
    mailbox #(transaction) gen2drv;   // Mailbox from Generator
    
    // 2. Memory Model (The "RAM")
    // Associative Array: Key = Address (32-bit), Value = Instruction (32-bit)
    bit [31:0] imem [int unsigned]; 
    
    // Address pointer for loading the program
    bit [31:0] current_load_addr;

    // 3. Constructor
    function new(virtual riscv_if.INSTR_BFM vif, mailbox #(transaction) gen2drv);
        this.vif = vif;
        this.gen2drv = gen2drv;
        this.current_load_addr = 0; // Start loading at address 0x0
    endfunction

    // 4. Main Run Task
    task run();
        $display("[DRV] Driver Initialized.");
        
        // We run two parallel threads:
        // Thread A: Loads the "Program" (Instructions) into memory
        // Thread B: Acts as the memory hardware (responds to PC)
        fork
            load_program();
            drive_bus();
        join_none
    endtask

    // ------------------------------------------------
    // Thread A: The Loader
    // ------------------------------------------------
    task load_program();
        transaction tr;
        forever begin
            // 1. Get transaction from Generator (Blocks if empty)
            gen2drv.get(tr);
            
            // 2. Convert high-level class to 32-bit Machine Code
            // 3. Store in our memory array
            imem[current_load_addr] = tr.get_instr_code();
            
            // 4. Debug Print
            $display("[MEM] Loaded Addr: 0x%0h | Hex: %h | Asm: %s", current_load_addr, imem[current_load_addr], tr.instr_name.name());
            
            // 5. Increment Address (RISC-V instructions are 4 bytes)
            current_load_addr += 4;
        end
    endtask

    // ------------------------------------------------
    // Thread B: The Bus Responder
    // ------------------------------------------------
    task drive_bus();
        forever begin
            // Synchronize to the clock
            @(posedge vif.clk);
            
            if (vif.reset) begin
                // During Reset, drive NOP (0x00000013 is ADDI x0, x0, 0) or just 0
                vif.instr <= 32'h00000013;
            end 
            else begin
                // The Processor has sent a PC (Address). We must provide the Data.
                
                // Check if we have an instruction loaded at this PC address
                if (imem.exists(vif.pc)) begin
                    vif.instr <= imem[vif.pc];
                end 
                else begin
                    // PC is pointing to empty memory (Crash/Bug scenario)
                    // Drive 0 or Unknown
                    vif.instr <= 32'hxxxxxxxx; 
                end
            end
        end
    endtask

endclass