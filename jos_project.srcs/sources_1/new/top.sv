`timescale 1ns / 1ps

// enable nie uzywane
module top( input clk, rst, output wire [7:0] leds,
            output reg oled_dc, output oled_res, output oled_sclk, output oled_sdin, output oled_vbat, output oled_vdd,
            output cs, sclk, input enable, input datain0, input datain1);
    
    localparam bits = 16, ndr = 5;
    
    logic clr_ctrl, clr;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    reg spi_fin;
    
    spi #(.bits(bits), .mode(0)) adc_master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .clr_ctrl(), .data2trans(),
    .clr(), .ss(cs), .sclk(sclk), .mosi(), .data_rec(data_rec));
    
    assign leds=data_rec[9:2];
    
    clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(en));
    
    
    spi #(.bits(bits),  .mode(1)) oled_master (.clk(clk), .rst(rst), .en(oled_en), .miso(), .clr_ctrl(), .data2trans(data2trans),
    .clr(), .ss(oled_cs), .sclk(oled_sclk), .mosi(oled_sdin), .data_rec());
    
    assign leds=data_rec[9:2];
    
//    clkdiv #(.div(20)) divider2(.clk(clk), .rst(rst), .en(oled_en));
     
    fsm_init oled_init(.clk(clk), .rst(rst), .en(1), .out(init_done),
     .vdd(oled_vdd), .res(oled_res), .vbat(oled_vbat),
     .oled_en(oled_en), .oled_fin(spi_fin), .oled_data(data2trans));
     
     
    always @(posedge clk) begin
        if(oled_en)
            #100
            spi_fin = 1'b1;
        else
            spi_fin = 1'b0;
        oled_dc = 1'b0;
    end
     
endmodule
