module PC_Reg(
    input [31:0] PCNext,
    input clk,
    input reset, //Asynchronous
    output reg [31:0] PC
);
    reg signed [3:0] num;

    // initial begin
    //     num = -2;
    //     $display("NUM = %d", num);
    // end
    


always@(posedge clk or posedge reset) begin
    if(reset) begin
        PC <= 0;
    end
    else begin
        PC <= PCNext;
    end
    
end

endmodule