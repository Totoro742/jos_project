`timescale 1ns / 1ps

typedef enum {Up_Idle, Up_ClearDC1, Up_ClearDC2, Up_SendCmd,
 Up_Spi1, Up_Spi2, Up_Back} update_state_t;


module update_page(input clk, input rst, input en, output fin, output logic dc, input logic [2:0] page,
                    input spi_fin, output logic spi_en, output logic [7:0] oled_data);
    
    localparam nbcmd = 4;
    logic [7:0] cmd_list = {
        8'h22, 
        {4'h0, page},
        8'h00,
        8'h10
    };

    logic [3:0] cnt_cmd;
//    logic spi_fin;
    update_state_t curr_state, next_state;

    always @(posedge clk, posedge rst) begin
        if(rst) oled_data <= 8'b0;
        else if(curr_state == Up_Spi1) oled_data <= cmd_list[cnt_cmd];
        else oled_data <= 8'b0;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) spi_en <= 1'b0;
        else if(curr_state == Up_Spi1 && ~spi_fin) spi_en <= 1'b1;
        else if(curr_state == Up_Spi2 && ~spi_fin) spi_en <= 1'b1;
        else spi_en <= 1'b0;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) cnt_cmd <= {4 {1'b0}};
        else if(cnt_cmd == nbcmd) cnt_cmd <= {4 {1'b0}};
        else if(curr_state == Up_Spi2 && spi_fin) cnt_cmd <= cnt_cmd + 1'b1;
    end

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
            Up_Spi1: begin
                //spi_en = 1'b1; 
                if(spi_fin) begin
                  //  spi_en = 1'b0; 
                    next_state = Up_Spi2;
                end
            end
            Up_Spi2: begin
                //spi_en = 1'b1; 
                if(spi_fin) begin
                    //spi_en = 1'b0; 
                    next_state = Up_Back;
                end
            end
            Up_Back: next_state = Up_Idle;
        endcase


    always @(posedge clk) begin
        if(curr_state == Up_Spi1) dc <= 0;
        else if(curr_state == Up_Spi2) dc <= 1;
    end

    always @(posedge clk, posedge rst) begin
        if(rst) curr_state <= Up_Idle;
        else    curr_state <= next_state;     
    end

endmodule
