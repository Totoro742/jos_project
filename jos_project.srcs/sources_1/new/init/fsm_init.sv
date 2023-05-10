`timescale 1ns / 1ps

typedef enum {In_Idle, In_Decision, In_Spi, In_Power,
 In_WaitPre, In_Delay, In_Clear, In_Done} init_state_t;


module fsm_init(input clk, input rst, input in, output out);
    logic en, cmd, vdd, res, vbat, spi_fin, cmd[16], delay_fin, cnt_cmd;
    localparam nbcmd = 16;
    init_state_t curr_state, next_state;
    
    initial
        curr_state = In_Idle;
    
    always @*
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
                if(cmd[0] != 9'h103)begin end
                else if(cmd[0] == 9'h103)begin end
                //delay_ms;
                //delay_en;
            In_Delay: if(delay_fin) next_state = In_Clear;
            In_Clear: if(cnt_cmd == nbcmd) next_state = In_Done;
            In_Done: if(en) next_state = In_Done;
                    else next_state = In_Idle;
        endcase


endmodule
