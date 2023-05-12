`timescale 1ns / 1ps


module tb_top();

localparam bits = 16, ndr = 5;

logic s, miso;
logic clk, rst, en;
logic [bits-1:0] data2trans;
logic [bits-1:0] data [3:0];
logic [7:0] leds;

spi_slave #(.bits(bits), .ndr(ndr)) slave (.cs(s), .sclk(sclk), .mosi(mosi), .miso(miso));
   
top uut (.clk(clk), .rst(rst), .cs(s), .sclk(sclk), .enable(en), .leds(leds), .datain0(miso), .datain1());



initial $readmemh("data.mem", data);

//d8 e6 1a c3
initial begin
    data2trans = data[0];
    #5
    clk = 0;
    rst = 0;
    en = 0;
    miso = 0;
    s = 1;
    #10
    rst = 1;

    #22 
    rst = 0;
    
    #22
    en = 1;
    
    #22
    en = 0;
    s = 0;
    
    #800
        data2trans = data[1];
    en = 1;
    
    #22
    en = 0;
        
    #800
        data2trans = data[2];
    en = 1;
    
    #22
    en = 0;
        
    #800
        data2trans = data[3];
    en = 1;
    
    #22
    en = 0;
    
end

initial forever #5 clk = ~clk;

endmodule
