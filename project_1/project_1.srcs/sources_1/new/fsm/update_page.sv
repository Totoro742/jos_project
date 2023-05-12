`timescale 1ns / 1ps

typedef enum {Up_Idle, Up_ClearDC1, Up_ClearDC2, Up_SendCmd,
 Up_Spi1, Up_Spi2, Up_Back} update_state_t;

module update_page(input clk, input rst, input in, output out);
    logic en, cnt_cmd, spi_fin;
    localparam nbcmd = 16;
    update_state_t curr_state, next_state;
    
    initial
        curr_state = Up_Idle;
        
    always @*    
        case(curr_state)
            Up_Idle: if(en) next_state = Up_ClearDC1;
            Up_ClearDC1: next_state = Up_SendCmd;
            Up_ClearDC2: next_state = Up_Idle;
            Up_SendCmd: begin
                if(cnt_cmd < nbcmd)
                    next_state = Up_Spi1;
                next_state = Up_ClearDC2; 
                end
            Up_Spi1: next_state = Up_Spi2;
            Up_Spi2: if(spi_fin) next_state = Up_Back;
            Up_Back: next_state = Up_Idle;
        endcase

endmodule
