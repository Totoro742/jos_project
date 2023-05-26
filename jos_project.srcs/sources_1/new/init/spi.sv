module spi #(parameter bits = 8, mode = 0) (input clk, rst, en, miso, clr_ctrl, input [bits-1:0] data2trans,
output clr, ss, sclk, mosi, output reg [bits-1:0] data_rec, output reg fin);
//Parametry czasu trwania:
//m - czas jednego bitu (w połowie zbocze opadające sclk)
//d - opóźnienia na początku
//Parametry obliczane:
//bm - rozmiar licznika czasu
//bdcnt - rozmiar licznika bitów
localparam m = 5, d = 2, bm = $clog2(m), bdcnt = $clog2(bits);
//kodowanie stanów
typedef enum {idle, shdown, progr, start} e_st;
e_st st, nst;
logic [bits-1:0] shr;
logic [bm-1:0] cnt;
logic [bdcnt:0] dcnt;
logic tmp, tm, cnten;

always @(posedge clk, posedge rst) begin
    fin <= 1'b0;
    if(rst)
        fin <= 1'b0;
    else if((dcnt == {(bdcnt+1){1'd0}}))
        fin <= 1'b1;
    end

always @(posedge clk, posedge rst)
    if(rst)
        st <= idle;
    else
        st <= nst;
//logika automatu
always @* begin
    nst = idle;
    cnten = 1'b1;
    case(st)
        idle: begin
            cnten = 1'b0;
            nst = en? (clr_ctrl?shdown:start):idle;
        end
        shdown: nst = (cnt == m-1) ? start:shdown;
        start: nst = (cnt == d) ? progr:start;
        progr: nst = (dcnt == {(bdcnt+1){1'd0}}) ? idle:progr;
    endcase
end
//licznik czasu trwania stanów
//i poziomów zegara transmisji
always @(posedge clk, posedge rst)
    if(rst)
        cnt <= {bm{1'b0}};
    else if(cnten)
        if(cnt == m | dcnt == {(bdcnt+1){1'd0}})
            cnt <= {bm{1'b0}};
        else
            cnt <= cnt + 1'b1;
// zakonczenie transmisji
//assign fin = (st == progr)?1'b0:1'b1;
//logika sygnałów wyjściowych
assign clr = (st == shdown)?1'b1:1'b0;
//chip select
assign ss = ((st == start) | (st == progr))?1'b0:1'b1;
//zegar transmisji
assign sclk = ((st == progr) & (cnt < (m/2 + 1)))?1'b1:1'b0;
//generator zezwolenie dla rejestru przesuwnego
//detektor zbocza opadającego zegara transmisji
always @(posedge clk, posedge rst)
    if(rst)
        tmp <= 1'b0;
    else
        tmp <= sclk;
assign spi_en = ~sclk & tmp;
//licznik bitów
always @(posedge clk, posedge rst)
    if(rst)
        dcnt <= bits;
    else if(spi_en)
        dcnt <= dcnt - 1'b1;
    else
    if(en & dcnt == {(bdcnt+1){1'd0}})
        dcnt <= bits;
    //rejestr przesuwny z wejściem miso z wyjściem mosi
assign mosi = shr[bits-1];
always @(posedge clk, posedge rst)
    if(rst)
        shr <= {bits{1'b0}};
    else if(en && mode)
        shr <= data2trans;
    else if(spi_en)
        shr <= {shr[bits-2:0],miso};
    //generator zezwolenia zapisu na wyjście
always @(posedge clk, posedge rst)
    if(rst)
        tm <= 1'b0;
    else
        tm <= ss;
assign en_out = ss & ~tm;
//rejestr wyjściowy
always @(posedge clk, posedge rst)
    if(rst)
        data_rec <= {bits{1'b0}};
    else if(en_out && ~mode)
        data_rec <= shr;
    //rejestr wyjściowy
endmodule