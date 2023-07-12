`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module fsm_init #(parameter modn = 100_000, delvbat = 100) (input clk, rst, en, 
    output reg dc, fin, res, sclk, sdo, vbat, vdd);      

    localparam nbcmd = 16;
    localparam N = $clog2(nbcmd);
    localparam del1ms = 8'h01;
    localparam del100ms = 8'h64;
    localparam VddOn = 9'h100, RstOn = 9'h102, RstOff = 9'h103, VbatOn = 9'h104;
    localparam reg [8:0] cmd_list[0:nbcmd-1] = '{VddOn, 9'h0AE, RstOn, RstOff, 9'h8D, 8'h14, 8'hD9, 8'hF1, VbatOn, 8'h81, 8'h0F, 8'hA1, 8'hC8, 8'hDA, 8'h20, 8'hAF};
    
    
    typedef enum {Idle, Decision, Power, WaitPre, Delay, Clear, Spi, Done} fsmst_e;
    fsmst_e current_state, next_state;
    
    
    reg [7:0] temp_delay_ms;
    reg temp_delay_en;
    reg temp_spi_en;
    reg [N-1:0] cnt_cmd;
    reg [8:0] cmd;
    
    spi #(.bits(8), .mode(1)) SPI_COMP(.clk(clk), .rst(rst), .en(temp_spi_en), .miso(), .data2trans(cmd[7:0]),
            .ss(), .sclk(sclk), .mosi(sdo), .data_rec(), .fin(temp_spi_fin));
    
    
    Delay #(.moduloN(modn), .nbits(8)) DELAY_COMP(.CLK(clk), .RST(rst), .DELAY_MS(temp_delay_ms), .DELAY_EN(temp_delay_en),
            .DELAY_FIN(temp_delay_fin));
    
    
    // State Machine regiter
    always @(posedge clk, posedge rst) 
        if(rst)  current_state <= Idle;
        else 	 current_state <= next_state;
        
    always @* begin
        next_state = Idle;
        dc = 1'b0;
        fin = 1'b0;
        temp_spi_en = 1'b0;
        temp_delay_en = 1'b0;
        case(current_state)
            Idle :     if(en)              next_state = Decision;
            Decision : if(cmd[8])	       next_state = Power;
                       else		           next_state = Spi;
            Power :                        next_state = WaitPre;
            WaitPre :  if (cmd == RstOff)  next_state = Clear;
                       else      		   next_state = Delay;
            Delay : begin
                       temp_delay_en = 1'b1;
                       if(temp_delay_fin)  next_state = Clear;
                       else				   next_state = Delay;
                    end
            Clear :    if (cnt_cmd == nbcmd-1) next_state = Done;
                       else           	       next_state = Idle;  
            Spi : begin
                       temp_spi_en = 1'b1;
                       if(temp_spi_fin)    next_state = Clear;
                       else    			   next_state = Spi;
                  end
            Done : begin
                       if(~en)             next_state = Idle;
                       else begin
                           fin = 1'b1;
                                           next_state = Done;
                       end
                   end
        endcase
    end
    
    
    always @(posedge clk, posedge rst) 
        if(rst)    temp_delay_ms <= del1ms;
        else
           if (~vbat)  temp_delay_ms <= del1ms;
           else        temp_delay_ms <= del100ms;
           
    always @(posedge clk, posedge rst) 
        if(rst) begin vdd <= 1'b1; res <= 1'b1; vbat <= 1'b1; end
        else	  case(cmd)
                            9'h100: vdd <= 1'b0; 
                            9'h102: res <= 1'b0;
                            9'h103: res <= 1'b1;
                            9'h104: vbat <= 1'b0;
                   endcase
    
    always @(posedge clk, posedge rst) 
        if(rst)  cnt_cmd <= 4'b0;
        else 
           if(cnt_cmd == nbcmd)
                 cnt_cmd <= 4'b0;
           else if (current_state == Clear)
                 cnt_cmd <= cnt_cmd + 1;
    
    always @(posedge clk, posedge rst) 
        if(rst) 
               cmd <= 9'h0;
        else if((current_state == Idle) & en)
               cmd <= cmd_list[cnt_cmd];

endmodule

