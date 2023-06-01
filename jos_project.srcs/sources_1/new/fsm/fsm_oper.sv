`timescale 1ns / 1ps

typedef enum {idle, screen, page, page_init, send_char,
 read_mem, spi1, spi2, back, time_disp, done} oper_state_t;


module fsm_oper(input clk, input rst, input en, output fin, output logic dc,
                input spi_fin, output logic spi_en, output logic [7:0] oled_data);
    
    `include "screen.vh"

    localparam nb_screens = 2'b11, nb_pages = 3'b100, nb_letters = 5'b10000, nb_columns = 4'b1000;
    
    reg [11:0] del4s = 12'd4000;
    reg[11:0] del1s = 12'd1000;
    reg [7:0] current[0:3][0:15];
    reg addr;
    reg spi_data_data;
    reg delay_ms;

    reg [1:0] cnt_screen;
    reg [2:0] cnt_page;
    reg [4:0] cnt_ind;
    reg [6:0] cnt_clm;
    reg spi_en_data, delay_en, page_en, page_fin, delay_fin;
    
    oper_state_t curr_state, next_state;
    
    update_page pager(.clk(clk), .rst(pager_rst), .en(pager_en), .fin(page_fin), .dc(up_dc));
    
    rom CHAR_LIB_COM(.clk(clk), .en(romen), .addr(addr), .dataout(romout));
    assign romen = (curr_state == read_mem);
    assign fin = (curr_state == done);
    
    //fsm
    always @* begin
    next_state = idle;
        case(curr_state) 
            idle: next_state = en ? screen : idle;
            screen: next_state = page;
            page: next_state = page_fin ? send_char : page;
            send_char: next_state = read_mem;
            read_mem: next_state = spi1;
            spi1: next_state = spi2;
            spi2: next_state = spi_fin ? back : spi2;
            back: if(cnt_page == 3'b100) next_state = time_disp;
                  else if(cnt_ind == 5'b10000) next_state = page_init;
                  else next_state = send_char;
            page_init: next_state = page;
            time_disp: if (cnt_screen == nb_screens) next_state = done;
		          else next_state = delay_fin?screen:time_disp;
            done: next_state = en ? done : idle;            
        endcase
    end

    always @(posedge clk, posedge rst) begin
        if(rst) curr_state <= idle;
        else    curr_state <= next_state;     
    end
    
    always @(posedge clk, posedge rst)
	   if(rst)
		  spi_data_data <= 8'b0;
	   else if(curr_state == read_mem)
		  spi_data_data <= romout;
        

    always @(posedge clk, posedge rst)
	   if(rst)
		  addr <= 11'b0;
	   else if (curr_state == send_char)
		  addr <= {current[cnt_page][cnt_ind], cnt_clm};
		  
    always @(posedge clk, posedge rst)
	   if(rst)
		  delay_ms <= 12'b0;
	   else if(curr_state == screen)
		  case(cnt_screen)
			 2'b00: delay_ms <= del4s;
			 2'b01: delay_ms <= del1s;
		  endcase

    always @(posedge clk)
        if(rst)
            current <= clear_screen;
        else if(curr_state == screen)
            case(cnt_screen)
                2'b00: current <= alphabet_screen;
                2'b01: current <= clear_screen; 
                2'b10: current <= agh_screen;
            endcase
    
    always @(posedge clk, posedge rst)
        if(rst)
            cnt_screen <= 2'b0;
        else if (curr_state == idle)
            cnt_screen <= 2'b0;
        else if ((curr_state == back) & (cnt_page == nb_pages))
                cnt_screen <= cnt_screen + 1;
    
    always @(posedge clk)
        if(rst)
            cnt_page <= 3'b0;
        else if (curr_state == screen | curr_state == idle)
            cnt_page <= 3'b0;
        else if ((curr_state == back) & (cnt_ind == nb_letters))
               cnt_page <= cnt_page + 1;
           
    always @(posedge clk)
        if(rst)
            cnt_ind <= 5'b0;
        else if (curr_state == screen | curr_state == page_init | curr_state == idle)
            cnt_ind <= 5'b0;
        else if ((curr_state == back) & (cnt_clm == nb_columns - 1))
              cnt_ind <= cnt_ind + 1;
    
    always @(posedge clk)
        if(rst)
            cnt_clm <= 3'b0;
        else if (curr_state == idle)
            cnt_clm <= 2'b0;
        else if (curr_state == back)
           if (cnt_clm == nb_columns - 1)
               cnt_clm <= 3'b0;
           else
                cnt_clm <= cnt_clm + 1;
    
    always @(posedge clk, posedge rst)
        if(rst) 
            delay_en <= 1'b0;
        else if (curr_state == back & cnt_page == nb_pages) 
            delay_en <= 1'b1;
        else if (curr_state == time_disp & delay_fin)
            delay_en <= 1'b0;
    
    always @(posedge clk, posedge rst)
        if(rst) 
            spi_en_data <= 1'b0;
        else if(curr_state == spi1)
            spi_en_data <= 1'b1;
        else if (curr_state == spi2 & spi_fin)
            spi_en_data <= 1'b0;
    
    always @(posedge clk, posedge rst)
        if(rst) begin
            page_en = 1'b0;
            dc = 1'b1;
        end else 
        case(curr_state)
            screen: begin	
                page_en = 1'b1;
                dc = 1'b0;
            end
            page_init: if (~cnt_page[2]) begin
                page_en = 1'b1;
                dc = 1'b0;
            end
            page: if (page_fin) begin
                page_en = 1'b0;
                dc = 1'b1;
            end
        endcase
endmodule
