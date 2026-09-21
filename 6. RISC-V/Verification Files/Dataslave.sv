// -------------------------------------------------------------------------
// DataSlave.sv (Data Memory BFM)
// Acts as the RAM for Load/Store instructions.
// -------------------------------------------------------------------------

class data_slave;

    // 1. Handles
    virtual riscv_if.DATA_BFM vif; // Virtual Interface (Data Side)

    // 2. Memory Model
    // Key = Address (32-bit), Value = Data (32-bit)
    // We use 'int unsigned' for the key to handle full 32-bit address range cleanly
    bit [31:0] dmem [int unsigned]; 

    // 3. Constructor
    function new(virtual riscv_if.DATA_BFM vif);
        this.vif = vif;
    endfunction

    // 4. Main Run Task
    task run();
        $display("[DATA_SLAVE] Data Memory Initialized.");

        // Clear output initially
        vif.read_data <= 32'b0;

        forever begin
            // Synchronize to the clock
            @(posedge vif.clk);

            if (vif.reset) begin
                vif.read_data <= 32'b0;
                // Optional: clear dmem.delete(); if you want a blank slate on reset
            end
            else begin
                // ------------------------------------
                // WRITE OPERATION (Store)
                // ------------------------------------
                if (vif.mem_write) begin
                    dmem[vif.data_addr] = vif.write_data;
                    $display("[DATA_SLAVE] Write: Addr=0x%0h, Data=0x%0h", 
                             vif.data_addr, vif.write_data);
                end

                // ------------------------------------
                // READ OPERATION (Load)
                // ------------------------------------
                if (vif.mem_read) begin
                    if (dmem.exists(vif.data_addr)) begin
                        vif.read_data <= dmem[vif.data_addr];
                        $display("[DATA_SLAVE] Read Hit:  Addr=0x%0h, Data=0x%0h", 
                                 vif.data_addr, dmem[vif.data_addr]);
                    end
                    else begin
                        // Reading from uninitialized memory
                        // Return 0 or randomized garbage to test robustness
                        vif.read_data <= 32'b0; 
                        $display("[DATA_SLAVE] Read Miss: Addr=0x%0h (Returning 0)", vif.data_addr);
                    end
                end
                else begin
                    // If not reading, keeping read_data 0 is cleaner for waveforms
                    // though in real hardware it might float.
                    vif.read_data <= 32'b0;
                end
            end
        end
    endtask

endclass