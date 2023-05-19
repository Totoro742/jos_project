`timescale 1ns / 1ps

module oled_init_tb();

    logic clk, rst, oled_vdd, oled_res, oled_vbat;
    logic en, fin;

    fsm_init oled_init(.clk(clk), .rst(rst), .en(en), .out(fin), .vdd(oled_vdd), .res(oled_res), .vbat(oled_vbat));

    initial begin
        #5
        clk = 0;
        #10 rst = 1;
        #20 rst = 0;
        #20 en = 1;
        #100 en = 0;
        #1_000 $finish;
    end

    initial begin
        forever #5 clk = ~clk;
    end

endmodule
