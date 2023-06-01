`timescale 1ns / 1ps

module oled_init_tb();

    logic clk, rst, oled_vdd, oled_res, oled_vbat;
    logic en, fin, oled_fin, oled_en;
    logic [7:0] oled_data;
    fsm_init oled_init(.clk(clk), .rst(rst), .en(en), .out(fin), .vdd(oled_vdd), .res(oled_res), .vbat(oled_vbat),
         .oled_fin(oled_fin), .oled_en(oled_en), .oled_data(oled_data));

    initial begin
        #5
        clk = 0;
        #10 rst = 1;
        #20 rst = 0;
        #20 en = 1;
        #100 en = 0;
        #5_000_000 $finish;
    end

    always @(posedge clk) begin
        if(oled_en)
        #100
            oled_fin = 1'b1;
        else
            oled_fin = 1'b0;
            
    end

    initial begin
        forever #5 clk = ~clk;
    end

endmodule
