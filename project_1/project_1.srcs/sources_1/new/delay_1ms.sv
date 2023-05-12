`timescale 1ns / 1ps

module delay_1ms (input clk, input rst, output en);

    clkdiv #(.div(100_000)) divider(.clk(clk), .rst(rst), .en(en));

endmodule
