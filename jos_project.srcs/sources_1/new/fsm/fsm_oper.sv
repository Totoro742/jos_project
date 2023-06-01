`timescale 1ns / 1ps

typedef enum {Op_Idle, Op_Screen, Op_Page, Op_PageInit, Op_SendChar,
 Op_ReadMem, Op_Spi1, Op_Spi2, Op_Back, Op_TimeDisp, Op_Done} oper_state_t;


module fsm_oper(input clk, input rst, input en, output fin, output logic dc,
                input spi_fin, output logic spi_en, output logic [7:0] oled_data);
    
    string text_to_send = "abcd";
    string char = text_to_send[0];
    parameter text_size = text_to_send.len();
    logic [$clog2(text_size)-1:0] cnt_char;

    logic [15:0] characters [1:95] [1:16];

    logic [15:0] char_bits [1:16];
    logic [6:0] cnt_col;
    logic [15:0] column;
    logic [7:0] cursor;

    
    localparam delay_ms = 500;
    localparam n = 100; // zle nie o to chodzi
    logic page_fin, delay_fin;
    oper_state_t curr_state, next_state;
    logic [7:0] cnt_screen, cnt_page;

    logic up_dc;

    update_page pager(.clk(clk), .rst(pager_rst), .en(pager_en), .fin(page_fin), .dc(up_dc));

 // delay

    always @(posedge rst) begin
        $readmemh("char2pixels.mem", characters);
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnt_col <= 0;
        else if(curr_state == Op_PageInit)
            cnt_page <= (cnt_page + 1'b1) % 8;
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            column <= 0;
        else if(curr_state == Op_Back)
            column <= char_bits[cnt_col % 16];
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnt_col <= 0;
        else if(curr_state == Op_Back)
            cnt_col <= cnt_col + 1'b1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            char_bits <= 0;
        else if(curr_state == Op_Back)
            char_bits <= characters[cnt_char];
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnt_char <= {$clog2(text_size){ 1'b0 }};
        else if(curr_state == Op_Back)
            cnt_char <= (cnt_char + 1'b1) % text_size;
    end

    always @(posedge clk) begin
        dc <= up_dc;
        if(curr_state == Op_Spi1) dc <= 0;
        else if(curr_state == Op_Spi2) dc <= 1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            cnt_screen <= {n{ 1'b0 }};
        else if(curr_state == Op_Idle)
            cnt_screen <= {n{ 1'b0 }};
        else if(curr_state == Op_Back)
            cnt_screen <= cnt_screen +  1'b1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst)
            oled_data <= {n{ 1'b0 }};
        else if(curr_state == Op_Spi1)
            oled_data <= 2'hcd; // address
        else if(curr_state == Op_Spi2)
            oled_data <= 2'hab; // data
    end

    always @*
        case(curr_state) 
            Op_Idle: begin
                if(en) next_state = Op_Screen;
            end
            Op_Screen: begin
                cnt_page = 3'b000;
                next_state = Op_Page;
                // wielkosc calego tekstu wertykalnie
            end
            Op_Page: begin // page update ??
                pager_en = 1'b1;
                if(page_fin) begin
                    pager_en = 1'b0;
                    next_state = Op_SendChar;
                end 
            end
            Op_PageInit: begin // page var init ???
                if (cnt_page == 8) begin
                    char_cnt = 0;
                end
                next_state = Op_Page;
            end
            Op_SendChar: begin
                char_bit = characters[`int(char)-31]
                column = char_bit[1];
                p1 = column[7:0];
                p2 = column[15:8];
                char_cnt <= char_cnt + 1;
                next_state = Op_ReadMem;
            end
            Op_ReadMem: begin // read char from memory???
                 next_state = Op_Spi1;
            end
            Op_Spi1: begin
                spi_en = 1'b1;
                num_cnt = 0;
                if(spi_fin) begin
                    spi_en = 1'b0;
                    next_state = Op_Spi2;
                 end
            end
            Op_Spi2: begin
                spi_en = 1'b1;
                if(num_cnt == 16) begin
                    spi_en = 1'b0;
                    next_state = Op_Back;
                end
                else if(spi_fin) begin
                    clm_cnt <= clm_cnt + 1;
                    num_cnt <= num_cnt + 1;
                 end
            end
            Back: begin
                if(cnt_page == 7)
                    next_state = TimeDisp;
                else if(cnt_char == text_size)
                    next_state = PageInit;
                else
                    next_state = SendChar;
            end
            Op_TimeDisp: begin // delay - no change ??? : 1. end 2. screen re render
                 if(delay_fin)begin
                    if(cnt_screen == 127) // po tylu rerenderach wyswietlacz sie wylaczy
                        next_state = Op_Done;
                    else
                        next_state = Op_Idle;
                end
            end
            Op_Done: begin
            	if(~en) next_state = Op_Idle;
            end
        endcase
       
       
    always @(posedge clk, posedge rst) begin
        if(rst) curr_state <= Op_Idle;
        else    curr_state <= next_state;     
    end
    
endmodule
