`timescale 1ns / 1ps

module update_page(input clk, rst, en, spi_fin, input [1:0] page, output reg dc, spi_en, output [7:0] spi_data);

    localparam nbcmd = 4;
    localparam reg [7:0] cmd[0:3] = '{8'h22, 8'h00, 8'h00, 8'h10};
    
    typedef enum {Idle, ClearDC, SendCmd, SetDC, Transition1, Transition2, Transition3} states_e;
    states_e current_state, next_state;
    
    reg [2:0] cmd_cnt;
    
    //Update Page states
        //1. Sets DC to command mode
        //2. Sends the SetPage Command
        //3. Sends the Page to be set to
        //4. Sets the start pixel to the left column
        //5. Sets DC to data mode
                
    assign spi_data = (cmd_cnt == 2'd1) ? {cmd[cmd_cnt][7:2],page} : cmd[cmd_cnt];
    
    
    always @(posedge clk, posedge rst)
        if(rst) cmd_cnt <= 3'b0;
        else if (current_state == Transition3)
            cmd_cnt <= cmd_cnt + 1;
        else if (current_state == SetDC | current_state == ClearDC)
            cmd_cnt <= 3'b0;
    
    
    always @(posedge clk, posedge rst)
        if(rst)		current_state <= Idle;
        else    	current_state <= next_state;
    
    always @* begin
        next_state = Idle;
        dc = 1'b0;
        case(current_state)
            Idle :     next_state = en ? ClearDC : Idle;
            ClearDC :  next_state = SendCmd;
            SendCmd :   
                 if(cmd_cnt < nbcmd) 
                    next_state = Transition1;
                 else
                    next_state = SetDC;
    
            SetDC : begin
                    dc = 1'b1;
                    next_state = Idle;
            end
            Transition1 : next_state = Transition2;
            Transition2 : 
                 if(spi_fin) 
                        next_state = Transition3;
                 else
                        next_state = Transition2;
            Transition3 : next_state = SendCmd;
        endcase
    end
    
    
    always @(posedge clk, posedge rst)
        if(rst)  	spi_en <= 1'b0;
        else begin
            if (current_state == Transition1)  spi_en <= 1'b1;
            if (current_state == Transition3)  spi_en <= 1'b0;
        end
    
endmodule

