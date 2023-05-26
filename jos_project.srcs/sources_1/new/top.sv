`timescale 1ns / 1ps

typedef enum {Idle, Init, Oper, Done} top_state_t;


// enable nie uzywane
module top( input clk, rst, output wire [7:0] leds,
            output oled_dc, output oled_res, output oled_sclk, output oled_sdin, output oled_vbat, output oled_vdd,
            output cs, sclk, input enable, input datain0, input datain1);
    
    localparam bits = 16;
    logic [bits-1:0] data2trans;
    wire [bits-1:0] data_rec;
    reg [bits-1:0] sh_reg;
    
    
    // ADC
    spi #(.bits(bits)) adc_master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .clr_ctrl(), .data2trans(data2trans),
    .clr(), .ss(cs), .sclk(sclk), .mosi(mosi), .data_rec(data_rec));

    /*
    logic [bits-1:0] oled_data;
    assign leds=data_rec[9:2];
    clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(en));
    
    logic init_done, oper_done;
    logic init_en, oper_en;
    top_state_t curr_state, next_state;





    logic oled_en, oled_cs;


// OLED
    spi #(.bits(bits)) oled_master (.clk(clk), .rst(rst), .en(oled_en), .miso(), .clr_ctrl(), .data2trans(oled_data),
    .clr(), .ss(oled_cs), .sclk(oled_sclk), .mosi(), .data_rec());
    
    fsm_init oled_init(.clk(clk), .rst(rst), .en(init_en), .out(init_done),
     .vdd(oled_vdd), .res(oled_res), .vbat(oled_vbat),
     .oled_en(oled_en), .oled_fin(spi_fin), .oled_data(data));
    //fsm_oper oled_oper(.clk(clk),  .rst(rst), .en(oper_en), .fin(oper_done), .dc(oled_dc));


    always @(posedge clk, posedge rst) begin
        if(curr_state == Init) begin
            init_en <= 1'b1;
        end else if(curr_state == Oper) begin
            init_en <= 1'b0;
            oper_en <= 1'b1;
        end else if(curr_state == Done) begin
            oper_en <= 1'b0;
        end
    end

    always @* begin
        case(curr_state)
            Idle: if(en) next_state = Init;
            Init: if(init_done) next_state = Oper;
            Oper: if(oper_done) next_state = Done;
            Done: next_state = Idle;
        endcase
    end


    always @(posedge clk, posedge rst) begin
        if(rst) begin
            curr_state <= Idle;
        end
        else
            curr_state <= next_state;     
    end
    */

endmodule
