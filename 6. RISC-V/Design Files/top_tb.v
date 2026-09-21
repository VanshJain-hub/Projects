module top_tb;
    reg clk, reset;
    wire [31:0] display_data;
    
    top_module DUT(.clk(clk), .reset(reset), .display_data(display_data));

    //initializing the clock
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 0;
        reset = 1;
        #20;
        reset = 0;

        #1000 $finish;
    end
    
    integer k;
    initial begin
        $dumpfile("execute.vcd");
        $dumpvars();
        $dumpvars(0, DUT.DP1.RF.regfile[0]);
        $dumpvars(0, DUT.DP1.RF.regfile[1]);
        $dumpvars(0, DUT.DP1.RF.regfile[2]);
        $dumpvars(0, DUT.DP1.RF.regfile[3]);
        $dumpvars(0, DUT.DP1.RF.regfile[4]);
        $dumpvars(0, DUT.DP1.RF.regfile[5]);
        $dumpvars(0, DUT.DP1.RF.regfile[6]);
        $dumpvars(0, DUT.DP1.RF.regfile[7]);
        $dumpvars(0, DUT.DP1.RF.regfile[8]);
        $dumpvars(0, DUT.DP1.RF.regfile[9]);
        $dumpvars(0, DUT.DP1.RF.regfile[10]);
        $dumpvars(0, DUT.DP1.RF.regfile[11]);
        $dumpvars(0, DUT.DP1.RF.regfile[12]);
        $dumpvars(0, DUT.DP1.RF.regfile[13]);
        $dumpvars(0, DUT.DP1.RF.regfile[14]);
        $dumpvars(0, DUT.DP1.RF.regfile[15]);
        $dumpvars(0, DUT.DP1.RF.regfile[16]);
        $dumpvars(0, DUT.DP1.RF.regfile[17]);
        $dumpvars(0, DUT.DP1.RF.regfile[18]);
        $dumpvars(0, DUT.DP1.RF.regfile[19]);
        $dumpvars(0, DUT.DP1.RF.regfile[20]);
        $dumpvars(0, DUT.DP1.RF.regfile[21]);
        $dumpvars(0, DUT.DP1.RF.regfile[22]);
        $dumpvars(0, DUT.DP1.RF.regfile[23]);
        $dumpvars(0, DUT.DP1.RF.regfile[24]);
        $dumpvars(0, DUT.DP1.RF.regfile[25]);
        $dumpvars(0, DUT.DP1.RF.regfile[26]);
        $dumpvars(0, DUT.DP1.RF.regfile[27]);
        $dumpvars(0, DUT.DP1.RF.regfile[28]);
        $dumpvars(0, DUT.DP1.RF.regfile[29]);
        $dumpvars(0, DUT.DP1.RF.regfile[30]);
        $dumpvars(0, DUT.DP1.RF.regfile[31]);
    end



endmodule