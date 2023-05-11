`timescale 1ns / 1ps

typedef enum {In_Idle, In_Decision, In_Spi, In_Power,
 In_WaitPre, In_Delay, In_Clear, In_Done} init_state_t;


module fsm_init(input clk, input rst, input in, output out);
    logic vdd, res, vbat;
    logic  en, spi_fin, delay_fin;
    logic cnt_cmd;
    
    logic cmd[16] = {
        9'h100, 9'h0AE,
        9'h102, 9'h103,
        9'h08D, 9'h014,
        9'h0D9, 9'h0F1,
        9'h104, 9'h081,
        9'h00F, 9'h0A1,
        9'h0C8, 9'h0DA,
        9'h020, 9'h0AF
    };
    logic values[16] = {
        // ========== SPI ===============
        // h0ae - 1010111x gdzie x = 0 display off
        // h0af - 1010111x gdzie x = 1 display on
        // h0a1 - 1010000x gdzie x = 1 adres 127 jest zamapowany na seg0    
        // h020 - 001000ab gdzie ab = 00 - horizontal addr mode
        //                gdzie ab = 01 - vertical addr mode
        //                gdzie ab = 10 - page addr mode
        //                gdzie ab = 11 - invalid
        // h014 - 0001abcd gdzie abcd = 0000 - on reset, set higher column for start address - pasge addressing
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
    };
    localparam nbcmd = 16;
    init_state_t curr_state, next_state;
    
    initial
        curr_state = In_Idle;
    
    always @(posedge clk, posedge rst)
        case(curr_state)
            In_Idle: if(en || cmd[0]) next_state = In_Decision; // cmd[0]???
            In_Decision: 
                if(cmd[8] == 0)
                    next_state = In_Spi;
                else if(cmd[8] == 1)
                    next_state = In_Power;
            In_Spi: if(spi_fin) next_state = In_Clear;
            In_Power: begin
               // vdd;
             //   res;
               // vbat;
            end
            In_WaitPre: 
                if(cmd[cnt_cmd] != 9'h103)begin 
                
                end
                else if(cmd[cnt_cmd] == 9'h103)begin 
                
                end
                //delay_ms;
                //delay_en;
            In_Delay: if(delay_fin) next_state = In_Clear;
            In_Clear: if(cnt_cmd == nbcmd) next_state = In_Done;
            In_Done: if(en) next_state = In_Done;
                    else next_state = In_Idle;
        endcase

    always @(posedge clk, posedge rst)
        if(rst)
            cnt_cmd <= 0;
        else
            cnt_cmd <= cnt_cmd + 1;

endmodule
