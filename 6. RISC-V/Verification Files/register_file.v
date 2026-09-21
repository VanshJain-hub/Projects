module Register_File (
    input  [4:0]  RA1,  
    input  [4:0]  RA2,  
    input  [4:0]  WA3,  
    input  [31:0] WD3,  
    input         WE3,  
    input         CLK,  
    output [31:0] RD1,  
    output [31:0] RD2,
    output [31:0] display_data
);

    reg [31:0] regfile [0:31]; 

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regfile[i] = 32'd0; 
    end

    assign RD1 = (RA1 == 0) ? 32'd0 : regfile[RA1];
    assign RD2 = (RA2 == 0) ? 32'd0 : regfile[RA2];

    always @(posedge CLK) begin
        if (WE3 && WA3!=0)
            regfile[WA3] <= WD3;
    end
    assign display_data = regfile[4];
endmodule
