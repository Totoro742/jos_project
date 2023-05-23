`timescale 1ns / 1ps

typedef enum {Up_Idle, Up_ClearDC1, Up_ClearDC2, Up_SendCmd,
 Up_Spi1, Up_Spi2, Up_Back} update_state_t;


// Wielokrotne podpiecie na wyzszym poziomie dla dc ????
module update_page(input clk, input rst, input en, output fin, output logic dc);
    logic cnt_cmd, spi_fin;
    localparam nbcmd = 16;
    update_state_t curr_state, next_state;
    logic spi_en, spi_en_r;

    localparam bits = 8;
    logic clr_ctrl, clr;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    logic [2:0] cnt_spi;
    logic [7:0] leds;

    spi #(.bits(bits)) master_oled (.clk(clk), .rst(rst), .en(spi_en), .miso(), .clr_ctrl(clr_ctrl), .data2trans(),
    .clr(clr), .ss(s), .sclk(sclk), .mosi(mosi), .data_rec(data_rec), .fin(spi_fin));

    assign spi_en = spi_en_r;

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
                spi_en_r = 1'b1; 
                if(spi_fin) begin
                    spi_en_r = 1'b0; 
                    next_state = Up_Spi2;
                end
            end
            Up_Spi2: begin
                spi_en_r = 1'b1; 
                if(spi_fin) begin
                    spi_en_r = 1'b0; 
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
        if(rst) begin
            cnt_cmd <= 0;
            curr_state <= Up_Idle;
        end
        else
            curr_state <= next_state;     
    end

endmodule
