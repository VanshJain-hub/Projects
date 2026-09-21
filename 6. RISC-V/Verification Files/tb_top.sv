// -------------------------------------------------------------------------
// tb_top.sv
// Updated Top-Level Testbench
// -------------------------------------------------------------------------
`include "interface.sv"
`include "Environment.sv"

// Note: You must update your top_module definition to have these ports!
// `include "top_module.v" 

module tb_top;

    // 1. Clock and Reset
    bit clk;
    bit reset;
    
    // Clock Generation (Same as your file)
    always #5 clk = ~clk; [cite: 2]

    initial begin
        clk = 0;
        reset = 1;
        #20 reset = 0; [cite: 4]
    end

    // 2. Interface Instance
    riscv_if intf(clk, reset);

    // 3. DUT Instantiation
    // I have mapped the interface to where these signals SHOULD be on your top_module.
    // You must modify "top_module" to accept these external memory connections.
    top_module DUT (
        .clk            (clk),
        .reset          (reset),
        
        // --- NEW PORTS YOU MUST ADD TO top_module ---
        // The processor outputs a PC, we give it an Instruction
        .pc_out         (intf.pc),       
        .instr_in       (intf.instr),    
        
        // The processor requests Data Memory access
        .mem_write      (intf.mem_write), 
        .mem_read       (intf.mem_read),  
        .alu_result     (intf.data_addr), // Address comes from ALU result
        .write_data     (intf.write_data),
        .read_data      (intf.read_data),
        
        // Keep your existing debug port if needed
        .display_data   () // Left unconnected for now
    );

    // 4. Whitebox Connections (UPDATED)
    // Connecting internal Register File to Interface for the Scoreboard
    // Path derived from your dumpvars: DUT.DP1.RF.regfile
    genvar i;
    generate
        for (i=0; i<32; i++) begin : spy_regs
            // We bind the interface array to your internal Verilog array
            assign intf.gp_regs[i] = DUT.DP1.RF.regfile[i]; 
        end
    endgenerate

    // 5. Test Program
    environment env;

    initial begin
        // Pass the interface to the environment
        env = new(intf);
        
        // Wait for reset
        #30;
        
        // Run the verification
        env.test();
    end

    // Dump Waves
    initial begin
        $dumpfile("verification.vcd");
        $dumpvars;
    end

endmodule