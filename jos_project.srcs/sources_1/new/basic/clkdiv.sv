`timescale 1ns / 1ps


module clkdiv #(parameter div=50_000_000) (
    input clk, rst,
    output logic en);

    // Number of bits
    localparam nb = $clog2(div);
    // Counter
    logic [nb-1:0] cnt;
    
    always @(posedge clk, posedge rst)
        if(rst)               cnt <= {nb{ 1'b0 }};
        else if (cnt == div)  cnt <= {nb{ 1'b0 }};
        else                  cnt <= cnt + 1'b1;
            
    always @(posedge clk, posedge rst)
        if(rst)               en <= 1'b0;
        else if (cnt == div)  en <= 1'b1;
        else                  en <= 1'b0;

endmodule
