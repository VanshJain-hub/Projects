// -------------------------------------------------------------------------
// Environment.sv
// The Container: Instantiates and connects all verification components
// -------------------------------------------------------------------------
`include "Transaction.sv"
`include "Generator.sv"
`include "DirectedGenerator.sv"
`include "Driver.sv"
`include "DataSlave.sv" 
`include "Monitor.sv"
`include "Scoreboard.sv"
`include "Subscriber.sv"

class environment;
    
    // 1. Component Handles
    generator   gen;
    driver      drv;
    data_slave  d_slave;
    monitor     mon;
    scoreboard  scb;
    subscriber  cov;
    
    // 2. Communication Channels (Mailboxes)
    mailbox #(transaction) gen2drv_mbx; // Generator -> Driver
    mailbox #(transaction) mon2scb_mbx; // Monitor -> Scoreboard
    mailbox #(transaction) mon2cov_mbx; //Monitor -> Subscriber for coverage
    
    // 3. Virtual Interface (Passed from Top)
    virtual riscv_if vif;

    // 4. Constructor
    function new(virtual riscv_if vif);
        this.vif = vif;
        
        // Initialize Mailboxes
        gen2drv_mbx = new();
        mon2scb_mbx = new();
        mon2cov_mbx = new();
        
        // --- TEST SELECTION LOGIC ---
        if ($test$plusargs("DIRECTED")) begin
            $display("[ENV] Launching DIRECTED Generator...");
            gen = directed_generator::new(gen2drv_mbx, 4); 
        end
        else begin
            $display("[ENV] Launching RANDOM Generator...");
            gen = new(gen2drv_mbx, 100);
        end
        // -----------------------------


        // Create Components and Connect them
        // Note: We pass specific modports to Driver/Monitor for safety
        
        //gen     = new(gen2drv_mbx, 100); // Generate 100 Instructions
        drv     = new(vif.INSTR_BFM, gen2drv_mbx);
        d_slave = new(vif.DATA_BFM);
        mon     = new(vif.MON, mon2scb_mbx);
        scb     = new(mon2scb_mbx, vif.MON);
        cov     = new(mon2cov_mbx);
    endfunction

    // 5. Test Execution
    task test();
        $display("[ENV] Environment Building Complete. Starting Simulation...");
        
        fork
            // Start all components in parallel
            gen.run();
            drv.run();
            d_slave.run();
            mon.run();
            scb.run();
            cov.run();
        join_none // Non-blocking: We let them run in the background

        // Wait for Generator to finish creating the program
        wait(gen.done.triggered);
        
        // Wait a bit longer for the last instruction to propagate through the pipeline
        #1000;
        
        $display("[ENV] Generator Finished. Simulation Ending.");
        $finish;
    endtask

    // 6. Post-Run Report
    task post_test();
        // You can add coverage reports or final scoreboard summaries here
    endtask

endclass