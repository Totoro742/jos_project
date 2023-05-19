`timescale 1ns / 1ps

typedef enum {In_Idle, In_Decision, In_Spi, In_Power,
 In_WaitPre, In_Delay, In_Clear, In_Done} init_state_t;

    
logic [8:0] cmd_list[16] = {
    9'h100, 9'h0AE,
    9'h102, 9'h103,
    9'h08D, 9'h014,
    9'h0D9, 9'h0F1,
    9'h104, 9'h081,
    9'h00F, 9'h0A1,
    9'h0C8, 9'h0DA,
    9'h020, 9'h0AF
};


    // ========== SPI ===============
    // h0ae - 1010111x gdzie x = 0 display off
    // h0af - 1010111x gdzie x = 1 display on
    // h0a1 - 1010000x gdzie x = 0 (reset) adres 0 jest zamapowany na seg0    
    // h020 - 001000ab gdzie ab = 00 - horizontal addr mode
    //                gdzie ab = 01 - vertical addr mode
    //                gdzie ab = 10 - page addr mode (reset)
    //                gdzie ab = 11 - invalid
    // h014 - 0001abcd gdzie abcd = 0000 - (reset) set higher column for start address in page addressing mode
    // h0da - 11011010 ?
    //        - 00ab0010 gdzie a = 0 - reset, disable com left/right remap
    //                          a = 1 - enable com left/right map
    //                          b = 0 - sequentail com pin configuration
    //                          b = 1 - reset, alterenatirve com left/right remap
    // h0c8 - 1100x000 gdzie x = 1 - remap mode. scan from com[n-1] to com0 (n - multiplex ratio)
    // h00f - 0000abcd gdzie abcd - 0000 - on reset, set lower nibble of the column start address register for page ddress mode
    // h081 - 10000001
    //          -abcdefgh - set contrast value reset = 0x7h
    // h0f1 - ?? - wyglada ze jest to opisane w 0d9
    // h0d9 - 11011011
    //          abcdefgh - abcd - dlugosc fazy 1 przed naladowaniem 1-15 cykli zegara
    //                      efgh -||- 2 -||- - reset w oby 0x02
    // h08d - 10001101
    //          **010x00 gdzie x - 0 disable charge pump (reset)
    //                              1 enable charge pump during display on



//logic values[16] = {
//    
//};


// output dc ?
module fsm_init(input clk, input rst, input en, output out, output logic vdd, output logic res, output logic vbat);
    //logic vdd, res, vbat;
    logic spi_fin, delay_fin, delay_en, delay_rst;
    logic [3:0] cnt_cmd;
    logic [8:0] cmd;
    logic spi_en, spi_en_r;
    logic fin;
    logic cs, s;

    localparam nbcmd = 16;
    init_state_t curr_state, next_state;
    
    localparam delay_ms = 1;
    localparam bits = 8;
    logic clr_ctrl, clr;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    logic [2:0] cnt_spi;
    logic [7:0] leds;

    assign out = fin;
    assign s = cs;
    assign spi_en = spi_en_r;
    assign sin = cmd[cnt_spi];
    assign mosi = leds[7];
    
    // en - potrzebne do licznika bitow - uruchomienie transmisji
    // miso - input
    // clr_ctrl, clr - niepotrzebne
    // ss, sclk - generowane przez slave przy transmisji
    // fin - informuje o zakonczeniu transmisji
    // mosi - output
    // data_rec - input
    // data2trans  - niestosowane
    spi #(.bits(bits)) master_oled (.clk(clk), .rst(rst), .en(spi_en), .miso(), .clr_ctrl(clr_ctrl), .data2trans(),
    .clr(clr), .ss(s), .sclk(sclk), .mosi(mosi), .data_rec(data_rec), .fin(spi_fin));
    
   // clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(spi_en)); // dodanie en i out - out = spi_en, en = spi_en_r
    shreg shift(.clk(clk), .rst(rst), .en(spi_en), .sin(sin), .leds(leds));
    

    delay #(.delay_ms(delay_ms)) waiter(.clk(clk), .rst(delay_rst), .en(delay_en), .out(delay_fin));


    always @*
        case(curr_state)
            In_Idle: begin
                fin = 1'b0;
                if(en || cnt_cmd) next_state = In_Decision;
            end
            In_Decision: 
                if(cmd[8] == 0) begin
                    //cs = 1'b0;
                    next_state = In_Spi;
                end
                else if(cmd[8] == 1)
                    next_state = In_Power;
            In_Spi: begin
                spi_en_r = 1'b1;
                if(spi_fin) begin
                    spi_en_r = 1'b0;
                    //cs = 1'b1;
                    next_state = In_Clear;
                end
            end
            In_Power: begin
                case (cmd)
                    9'h100: vdd = 1'b0;
                    9'h102: res = 1'b1;
                    9'h103: res = 1'b0;
                    9'h104: vbat = 1'b0;
                endcase
                next_state = In_WaitPre;
            end
            In_WaitPre: begin
                if(cmd != 9'h103)begin 
                    //waiter.delay_ms = (cmd == 9'h104) ? 100 : 1;
                    delay_rst = 1'b1;
                    delay_en = 1'b1;
                    next_state = In_Delay;
                end
                else begin 
                    next_state = In_Clear;
                end
            end
            In_Delay: begin
                delay_rst = 1'b0;
                if(delay_fin) begin
                    delay_en = 1'b0;
                    next_state = In_Clear;
                end
            end
            In_Clear: 
                if(cnt_cmd < nbcmd) begin
                    cnt_cmd = cnt_cmd + 1'b1;
                    next_state = In_Idle;
                end
                else next_state = In_Done;
            In_Done: begin
                fin = 1'b1;
                cnt_cmd = 1'b0;
                if(~en) next_state = In_Idle;
            end
        endcase


    always @(posedge clk, posedge rst) begin
        if(rst) cmd <= cmd_list[0];
        else    cmd <= cmd_list[cnt_cmd];
    end


    always @(posedge clk, posedge rst) begin
        if(rst) begin
            cnt_cmd <= 0;
            curr_state <= In_Idle;
        end
        else
            curr_state <= next_state;     
    end

    
    localparam max_spi = 8;
    always @(posedge clk, posedge rst, posedge sclk) begin
        if(rst) cnt_spi = 0;
        if(sclk & spi_en_r) 
            if(cnt_spi < max_spi)begin
             
             cnt_spi = cnt_spi + 1;
            end
            else cnt_spi = 0;
    end

endmodule
