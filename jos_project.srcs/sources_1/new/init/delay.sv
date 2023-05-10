`timescale 1ns / 1ps

typedef enum {Dly_Idle, Dly_Hold, Dly_Done} delay_state_t;


module delay(input clk, input rst, input in, output out);
    logic en, cnt_ms, delay_ms;
    delay_state_t curr_state, next_state;
    
    initial
        curr_state = Dly_Idle;
    
    always @*
        case(curr_state)
            Dly_Idle: if(en) next_state = Dly_Hold;
            Dly_Hold: if(cnt_ms == delay_ms) next_state = Dly_Done;
            Dly_Done: if(~en) next_state = Dly_Idle;
        endcase
    

endmodule
