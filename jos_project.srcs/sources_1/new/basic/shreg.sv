`timescale 1ns / 1ps


module shreg(
    input clk, rst, en, sin,
    output [7:0] leds
    );
    
    // Shift_Register
    logic [7:0] shr;    
        
    always @(posedge clk, posedge rst)
        if(rst)
            shr <= 8'b0;
        else if(en)
            shr <= { shr[6:0], sin };
    
    assign leds = shr;
    
    
endmodule
