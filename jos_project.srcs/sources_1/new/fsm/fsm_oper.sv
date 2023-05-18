`timescale 1ns / 1ps

typedef enum {Op_Idle, Op_Screen, Op_Page, Op_PageInit, Op_SendChar,
 Op_ReadMem, Op_Spi1, Op_Spi2, Op_Back, Op_TimeDisp, Op_Done} oper_state_t;


module fsm_oper(input clk, input rst, input en, output out);
    string text_to_send = "abcd";

    logic [7:0] characters [1:5];
    initial $readmemh("char2pixels.mem", characters);

    localparam delay_ms = 500;
    localparam n = $clog2(delay_ms); // zle nie o to chodzi
    logic page_fin, spi_fin, delay_fin;
    oper_state_t curr_state, next_state;
    logic cnt_screen, cnt_page;

    update_page pager(.clk(clk), .rst(pager_rst), .en(pager_en), .fin(page_fin));

    always @*
        case(curr_state) 
            Op_Idle: begin
                cnt_screen = {n{ 1'b0 }};
                delay_ms = 500;
                if(en) next_state = Op_Screen;
            end
            Op_Screen: begin
                cnt_page = 3'b000;
                cnt_screen = cnt_screen +  1'b1;
                next_state = Op_Page;
            end
            Op_Page: begin
                if(page_fin) begin
                    cnt_page = cnt_page + 1'b1;
                    next_state = Op_SendChar;
                end 
            end
            Op_PageInit: begin
                if (cnt_page == 8) cnt_page = 3'b0;
                next_state = Op_Page;
            end
            Op_SendChar: begin
                 next_state = Op_ReadMem;
            end
            Op_ReadMem: begin
                 next_state = Op_Spi1;
            end
            Op_Spi1: begin
                 next_state = Op_Spi2;
            end
            Op_Spi2: begin
                 if(spi_fin) next_state = Op_Back;
            end
            //Back: next_state = SendChar, PageInit, TimeDisp;
            Op_TimeDisp: begin
                 if(delay_fin)begin
                        next_state = Op_Idle;
                        next_state = Op_Done;
                        end
            end
            Op_Done: begin
            	if(~en) next_state = Op_Idle;
            end
        endcase
       
       
    always @(posedge clk, posedge rst) begin
        if(rst)
            curr_state <= Op_Idle;
        else
            curr_state <= next_state;     
    end
endmodule
