`timescale 1ns / 1ps

typedef enum {Op_Idle, Op_Screen, Op_Page, Op_PageInit, Op_SendChar,
 Op_ReadMem, Op_Spi1, Op_Spi2, Op_Back, Op_TimeDisp, Op_Done} oper_state_t;


module fsm_oper(input clk, input rst, input en, output fin, output logic dc);
    string text_to_send = "abcd";

    string char = text_to_send[0];

    logic [15:0] characters [1:95] [1:16];
    initial $readmemh("char2pixels.mem", characters);

    logic [15:0] char_bit [1:16];
    logic [15:0] column;
    logic [7:0] p1;
    logic [7:0] p2;

    // offset calculation

    localparam delay_ms = 500;
    localparam n = $clog2(delay_ms); // zle nie o to chodzi
    logic page_fin, spi_fin, delay_fin;
    oper_state_t curr_state, next_state;
    logic cnt_screen, cnt_page;


    localparam bits = 8;
    logic clr_ctrl, clr;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    logic [2:0] cnt_spi;
    logic [7:0] leds;
    logic spi_en;

    spi #(.bits(bits)) master_oled (.clk(clk), .rst(rst), .en(spi_en),
     .miso(), .clr_ctrl(), .data2trans(data2trans),
    .clr(clr), .ss(s), .sclk(sclk), .mosi(mosi), .data_rec(data_rec), .fin(spi_fin));

    logic up_dc;

    update_page pager(.clk(clk), .rst(pager_rst), .en(pager_en), .fin(page_fin), .dc(up_dc));

 // delay

    always @(posedge clk) begin
        dc <= up_dc;
        if(curr_state == Op_Spi1) dc <= 0;
        else if(curr_state == Op_Spi2) dc <= 1;
    end

    always @*
        case(curr_state) 
            Op_Idle: begin
                cnt_screen = {n{ 1'b0 }};
                //delay_ms = 500;
                if(en) next_state = Op_Screen;
            end
            Op_Screen: begin
                cnt_page = 3'b000;
                cnt_screen = cnt_screen +  1'b1;
                next_state = Op_Page;
            end
            Op_Page: begin // page update ??
                pager_en = 1'b1;
                if(page_fin) begin
                    pager_en = 1'b0;
                    cnt_page = cnt_page + 1'b1;
                    next_state = Op_SendChar;
                end 
            end
            Op_PageInit: begin // page var init ???
                if (cnt_page == 8) begin
                    cnt_page = 3'b0;
                    char_cnt = 0;
                end
                next_state = Op_Page;
            end
            Op_SendChar: begin // ???
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
            Op_Spi1: begin // comm ??
                data2trans = data; // address
                spi_en = 1'b1;
                num_cnt = 0;
                if(spi_fin) begin
                    spi_en = 1'b0;
                    next_state = Op_Spi2;
                 end
            end
            Op_Spi2: begin // data ???
                data2trans = data; // data
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
            //Back: next_state = SendChar, PageInit, TimeDisp; // decision: 1. next page, 2. delay - screen finished, 3. draw chars on same page ???
            Op_TimeDisp: begin // delay - no change ??? : 1. end 2. screen re render
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
