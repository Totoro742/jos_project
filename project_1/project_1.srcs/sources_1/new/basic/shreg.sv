`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/15/2023 04:05:47 PM
// Design Name: 
// Module Name: shreg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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
