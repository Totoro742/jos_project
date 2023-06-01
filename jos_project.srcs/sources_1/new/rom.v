`timescale 1ns / 1ps

module rom(input clk, en, input [10:0] addr, output reg [7:0] dataout);

reg [7:0] mem [1023:0];

initial $readmemh("pixel_SSD1306.mem", mem);

always @(posedge clk)
    if(en) dataout <= mem[addr];
    
endmodule
