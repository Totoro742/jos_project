`timescale 1ns / 1ps


module delay_tb();

    localparam delay_ms = 1;
    logic clk, delay_rst, delay_en, delay_fin;
    
    delay #(.delay_ms(delay_ms)) waiter(.clk(clk), .rst(delay_rst), .en(delay_en), .out(delay_fin));

    initial begin
        #5
        clk = 0;
        delay_rst = 1;
        #20
        delay_rst = 0;
        #20
        delay_en = 1;
        #10000
        $finish;
    end
    
    always @(posedge delay_fin) delay_en = 0;

    initial forever #5 clk = ~clk;
    
endmodule
