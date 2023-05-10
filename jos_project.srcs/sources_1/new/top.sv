`timescale 1ns / 1ps

module top( input clk, rst, output cs, sclk, input enable, output wire [7:0] leds,input datain0, input datain1);
// enable nie uzywane

localparam bits = 16, ndr = 5;


logic clr_ctrl, clr;
logic [bits-1:0] data2trans;

wire [bits-1:0] data_rec;
reg [bits-1:0] sh_reg;
spi #(.bits(bits)) master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .clr_ctrl(clr_ctrl), .data2trans(data2trans),
.clr(clr), .ss(cs), .sclk(sclk), .mosi(mosi), .data_rec(data_rec));

assign leds=data_rec[9:2];

clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(en));

endmodule
