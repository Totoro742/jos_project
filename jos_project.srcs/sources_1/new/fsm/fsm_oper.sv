`timescale 1ns / 1ps

typedef enum {Op_Idle, Op_Screen, Op_Page, Op_PageInit, Op_SendChar,
 Op_ReadMem, Op_Spi1, Op_Spi2, Op_Back, Op_TimeDisp, Op_Done} 
oper_state_t;


module fsm_oper(input clk, input rst, input in, output out);
    logic en, page_fin, spi_fin, delay_fin;
    oper_state_t curr_state, next_state;
    
    always @*
        case(curr_state) 
            Op_Idle: if(en) next_state = Op_Screen;
            Op_Screen: next_state = Op_Page;
            Op_Page: if(page_fin) next_state = Op_SendChar;
            Op_PageInit: next_state = Op_Page;
            Op_SendChar: next_state = Op_ReadMem;
            Op_ReadMem: next_state = Op_Spi1;
            Op_Spi1: next_state = Op_Spi2;
            Op_Spi2: if(spi_fin) next_state = Op_Back;
            //Back: next_state = SendChar, PageInit, TimeDisp;
            Op_TimeDisp: if(delay_fin)begin
                        next_state = Op_Idle;
                        next_state = Op_Done;
                        end
            Op_Done:	if(~en) next_state = Op_Idle;
        endcase
    
endmodule
