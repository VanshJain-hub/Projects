// -------------------------------------------------------------------------
// Generator.sv
// Creates a sequence of randomized instructions (The Program)
// -------------------------------------------------------------------------
`ifndef GENERATOR_SV
`define GENERATOR_SV

`include "Transaction.sv"

class generator;
    
    // 1. Communication Variables
    transaction tr;                    // Handle for the object we create
    mailbox #(transaction) gen2drv;    // Mailbox to send data to Driver
    event done;                        // Event to trigger when we are finished

    // 2. Configuration
    int  instruction_count;            // How many instructions to generate

    // 3. Constructor
    // We pass the shared mailbox handle in the 'new' function
    function new(mailbox #(transaction) gen2drv, int count = 50);
        this.gen2drv = gen2drv;
        this.instruction_count = count;
    endfunction

    // 4. Main Task
    virtual task run();
        $display("[GEN] ---------------------------------------");
        $display("[GEN] Starting Generation of %0d Instructions", instruction_count);
        $display("[GEN] ---------------------------------------");

        repeat(instruction_count) begin
            // A. Create a new transaction object
            tr = new();

            // B. Randomize it
            // We can add inline constraints here if we want specific tests later
            if( !tr.randomize() ) begin
                $fatal("[GEN] Fatal Error: Randomization Failed!");
            end

            // C. Send a copy to the Driver
            gen2drv.put(tr);
            
            // Print what we just made
            tr.display("GEN"); 
        end
        
        $display("[GEN] Generation Complete. Triggering 'done' event.");
        -> done; //Triggering event completion
    endtask

endclass

`endif // GENERATOR_SV