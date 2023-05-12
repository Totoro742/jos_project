`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2023 11:51:58 AM
// Design Name: 
// Module Name: tb_oled
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


module tb_oled();

logic clk, rst, en, out,sig;

delay_1ms delay (.clk(clk), .rst(rst), .en(en));


delay #(.delay_ms(1)) del_1ms (.clk(clk), .rst(rst), .en(sig), .out(out));

initial begin
    sig = 0;
    clk = 0;
    rst = 0;
    
    #10
    rst = 1;
    
    #10
    rst = 0;
    sig = 1;
    
    #10
    sig = 0;
    
    #1_000_000
    $finish();

end

initial forever #5 clk = ~clk;

endmodule
