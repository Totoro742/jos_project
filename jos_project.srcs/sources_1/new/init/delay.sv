`timescale 1ns / 1ps

typedef enum {Dly_Idle, Dly_Hold, Dly_Done} delay_state_t;


module delay #(parameter delay_ms = 1) (input clk, input rst, input en, output out);
    logic [$clog2(delay_ms):0] cnt_ms;
    logic fin;
    logic delay_rst, delay_en;
    delay_state_t curr_state, next_state;
    
    assign out = fin;
    
    clkdiv #(.div(100_000)) delay_1ms(.clk(clk), .rst(delay_rst), .en(delay_en));

    
    always @* begin
        //next_state = Dly_Idle;
        case(curr_state)
            Dly_Idle: begin
                fin = 1'b0;
                cnt_ms = 1'b0;
                delay_rst = 1'b1;
                if(en) begin
                    next_state = Dly_Hold;
                end
            end
            Dly_Hold: begin
                delay_rst = 1'b0;
                if(cnt_ms == delay_ms) next_state = Dly_Done;
                else if(delay_en) cnt_ms = cnt_ms + 1'b1;
            end
            Dly_Done: begin
                fin = 1'b1;
                if(~en) next_state = Dly_Idle;
            end
        endcase
    end
    
    always @(posedge clk, posedge rst) begin
        if(rst)
            curr_state <= Dly_Idle;
        else
            curr_state <= next_state;     
    end
    
endmodule
