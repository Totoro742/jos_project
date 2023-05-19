`timescale 1ns / 1ps

// enable nie uzywane
module top( input clk, rst, output wire [7:0] leds,
            output oled_dc, output oled_res, output oled_sclk, output oled_sdin, output oled_vbat, output oled_vdd,
            output cs, sclk, input enable, input datain0, input datain1);
    
    localparam bits = 16, ndr = 5;
    
    logic clr_ctrl, clr;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    
    spi #(.bits(bits)) master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .clr_ctrl(clr_ctrl), .data2trans(data2trans),
    .clr(clr), .ss(cs), .sclk(sclk), .mosi(mosi), .data_rec(data_rec));
    
    assign leds=data_rec[9:2];
    
    clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(en));
    
    
    //fsm_init oled_init(.clk(clk), .rst(rst), .en(), .out(), .vdd(oled_vdd), .res(oled_res), .vbat(oled_vbat));
    
endmodule
