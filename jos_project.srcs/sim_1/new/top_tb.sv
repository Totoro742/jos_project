`timescale 1ns / 1ps


module top_tb();

logic [7:0] leds;
logic clk, rst, oled_dc, oled_res,oled_sclk, oled_sdin, oled_vbat, oled_vdd, cs, sclk, enable, datain0, datain1;

top uut (clk, rst, leds,
            oled_dc, oled_res, oled_sclk, oled_sdin, oled_vbat, oled_vdd,
            cs, sclk, enable, datain0, datain1);


initial begin
    clk = 0;
    rst = 1;
    #10
    rst = 0;
     #5_000_000 $finish;
    
end



initial forever #5 clk = ~clk;


endmodule
