`timescale 1ns / 1ps

typedef enum {Dly_Idle, Dly_Hold, Dly_Done} delay_state_t;


module delay #(parameter delay_ms = 1) (input clk, input rst, input en, output out);
    logic cnt_ms, del, fin;
    delay_state_t curr_state, next_state;
    
    assign out = del;
    
    
    initial begin
        curr_state = Dly_Idle;
        del = 0;
        fin = 0;
   end
    
    // ?????
    always @(posedge clk, posedge rst) begin
        if(rst)
            del = 0;
        else
            if(en && ~fin)
                del = 1;
            else if(fin)
                del = 0;         
    end
    
    always @(posedge clk) begin
        next_state = Dly_Idle;
        case(curr_state)
            Dly_Idle: begin
                fin = 0;
                if(en) next_state = Dly_Hold;
            end
            Dly_Hold: begin
                if(cnt_ms == delay_ms) next_state = Dly_Done;
                else delay_1ms cnt_1ms (.clk(clk), .rst(rst), .en(del));
            end
            Dly_Done: begin
                fin = 1;
                if(~en) next_state = Dly_Idle;
            end
        endcase
    end
    
    always @(posedge clk, posedge rst) begin
        if(rst)
            curr_state = Dly_Idle;
        else
            curr_state = next_state;     
    end
    
    always @(posedge clk, posedge rst)
        if(rst)
            cnt_ms <= 0;
        else
            cnt_ms <= cnt_ms + 1;
            
endmodule
