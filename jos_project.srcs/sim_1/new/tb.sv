`timescale 1ns / 1ps


module tb();

localparam bits = 8, ndr = 5;

logic s, sclk, mosi, miso;
logic clk, rst, en, clr_ctrl, clr, ss;
logic [bits-1:0] data2trans;
logic [bits-1:0] data [3:0];
logic [bits-1:0] data_rec;
logic fin;

spi_slave #(.bits(bits), .ndr(ndr)) slave (.cs(s), .sclk(sclk), .mosi(mosi), .miso(miso));
    
spi #(.bits(bits)) master (.clk(clk), .rst(rst), .en(en), .miso(miso), .clr_ctrl(clr_ctrl), .data2trans(data2trans),
.clr(clr), .ss(s), .sclk(sclk), .mosi(mosi), .data_rec(data_rec));


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

    #20 
    rst = 0;
    
    #20
    en = 1;
    
    #20
    en = 0;
    s = 0;
    
    #700
        data2trans = data[1];
    en = 1;
    
    #20
    en = 0;
        
    #700
        data2trans = data[2];
    en = 1;
    
    #20
    en = 0;
        
    #700
        data2trans = data[3];
    en = 1;
    
    #20
    en = 0;
    
end

initial forever #5 clk = ~clk;

endmodule
