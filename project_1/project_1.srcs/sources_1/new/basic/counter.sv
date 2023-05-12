`timescale 1ns / 1ps


// do poprawy
module counter #(parameter slow_clk=2**16, dl=15, nbt=2)(
    input clk, rst, butt_add, butt_sub,
    output [7:0] leds);
    

    logic [nbt-1:0] butt_deb;
    wire [nbt-1:0] butt_in = {butt_add, butt_sub};
    
    wire plus = butt_deb[0];
    wire minus = butt_deb[1];
    
    logic [7:0] cnt;
    assign leds = cnt;
    
    always @(posedge clk)
        if(rst)
            cnt <= 8'b0;
        else if (plus)
            cnt <= cnt + 1'b1;
        else if (minus)
            cnt <= cnt - 1'b1;
            
endmodule
