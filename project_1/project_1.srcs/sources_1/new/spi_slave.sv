module spi_slave #(parameter bits = 8, ndr = 5)
(input cs, sclk, mosi, output miso);
logic [bits-1:0] shr;
logic [bits-1:0] data_in [1:ndr];
logic [$clog2(ndr)-1:0] i = 0;
logic [bits-1:0] data_out [1:ndr];
logic [$clog2(ndr)-1:0] j = 1;

initial $readmemh("data.mem", data_out);

//rejestr przesuwny
assign #11 miso = shr[bits-1];
always @(negedge sclk)
    shr <= {shr[bits-2:0], mosi};
always @(negedge cs)
    shr <= data_out[j++];
always @(posedge cs)
    data_in[i++] <= shr; //zachowanie słowa odebranego
endmodule