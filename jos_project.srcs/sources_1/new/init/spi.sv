module spi #(parameter bits = 8, mode = 0) (input clk, rst, en, miso, input [bits-1:0] data2trans,
output ss, sclk, mosi, output reg [bits-1:0] data_rec, output reg fin);
    
    localparam m = 5;                // czas jednego bitu (w połowie zbocze opadające sclk)
    localparam d = 2;                // opóźnienia na początku
    localparam bm = $clog2(m);       // rozmiar licznika czasu
    localparam bdcnt = $clog2(bits); // rozmiar licznika bitów
    
    typedef enum {Idle, Progr, Start} e_st;
    e_st current_state, next_state;
    
    logic [bits-1:0] shr;
    logic [bm-1:0] cnt;
    logic [bdcnt:0] dcnt;
    logic tmp, tm, cnten;
    
    
    
    always @(posedge clk, posedge rst)
        if(rst)      current_state <= Idle;
        else         current_state <= next_state;
    
    //logika automatu
    always @* begin
        next_state = Idle;
        cnten = 1'b1;
        case(current_state)
            Idle: begin
                cnten = 1'b0;
                next_state = en ? Start : Idle;
            end
            Start: next_state = (cnt == d) ? Progr : Start;
            Progr: next_state = (dcnt == {(bdcnt+1){1'd0}}) ? Idle : Progr;
        endcase
    end
    
    
    //licznik czasu trwania stanów
    //i poziomów zegara transmisji
    always @(posedge clk, posedge rst)
        if(rst)        cnt <= {bm{1'b0}};
        else if(cnten)
            if(cnt == m | dcnt == {(bdcnt+1){1'd0}})
                       cnt <= {bm{1'b0}};
            else
                       cnt <= cnt + 1'b1;
    // zakonczenie transmisji
    always @(posedge clk, posedge rst) begin
        fin <= 1'b0;
        if(rst)       fin <= 1'b0;
        else if((dcnt == {(bdcnt+1){1'd0}}))
                      fin <= 1'b1;
    end
    
    
    
    //zegar transmisji
    assign sclk = ((current_state == Progr) & (cnt < (m/2 + 1))) ? 1'b1 : 1'b0;
    
    //detektor zbocza opadającego zegara transmisji
    always @(posedge clk, posedge rst)
        if(rst)     tmp <= 1'b0;
        else        tmp <= sclk;
    
    assign spi_en = ~sclk & tmp;
    
    //licznik bitów
    always @(posedge clk, posedge rst)
        if(rst)               dcnt <= bits;
        else if(spi_en)       dcnt <= dcnt - 1'b1;
        else if(en & dcnt == {(bdcnt+1){1'd0}})
                              dcnt <= bits;
    
    assign mosi = shr[bits-1];
    always @(posedge clk, posedge rst)
        if(rst)              shr <= {bits{1'b0}};
        else if(en && mode)  shr <= data2trans;
        else if(spi_en)      shr <= {shr[bits-2:0],miso};
    
    
    
    
    //chip select
    assign ss = ((current_state == Start) | (current_state == Progr)) ? 1'b0 : 1'b1;
        
    //generator zezwolenia zapisu na wyjście
    always @(posedge clk, posedge rst)
        if(rst)  tm <= 1'b0;
        else     tm <= ss;
    
    assign en_out = ss & ~tm;
    
    //rejestr wyjściowy
    always @(posedge clk, posedge rst)
        if(rst)                    data_rec <= {bits{1'b0}};
        else if(en_out && ~mode)   data_rec <= shr;
    


endmodule