`timescale 1ns / 1ps

typedef enum {Idle, Hold, Oper, Done} oled_state_t;


module oled_top(input clk, input rst, input in, output out);
    logic init_done, oper_done;
    oled_state_t curr_state, next_state;
    
    // fsm_init()
    // fsm_oper()
    
    
    initial begin
        curr_state = Idle;
    end
    
    always @*
        case(curr_state)
            Idle : next_state = Hold;
            Hold : if(init_done) next_state = Oper;
            Oper : if(oper_done) next_state = Done;
        endcase

endmodule
