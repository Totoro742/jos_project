`timescale 1ns / 1ps

typedef enum {Idle, Init, Oper, Done} top_state_t;

module top( input clk, rst, output wire [7:0] leds,
            output oled_dc, output oled_res, output oled_sclk, output oled_sdin, output oled_vbat, output oled_vdd,
            output cs, sclk, input datain0, input datain1);
    
    localparam bits = 16;
    
    wire [bits-1:0] data_rec;
    logic init_en, oper_en;
    logic init_dc, oper_dc;
    logic init_done, oper_done;
    logic init_sdo, data_sdo;

    reg spi_fin;
	wire init_sclk; // niepotrzebne ???

    top_state_t curr_state, next_state;
    
    spi #(.bits(bits), .mode(0)) ADC_master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .data2trans(),
    .ss(cs), .sclk(sclk), .mosi(), .data_rec(data_rec), .fin());

    assign leds=data_rec[9:2];

    
     spi #(.bits(bits), .mode(0)) Oled_slave (.clk(clk), .rst(rst), .en(en), .miso(), .data2trans(oled_data),
    .ss(), .sclk(oled_sclk), .mosi(data_sdo), .data_rec(), .fin(spi_fin));
   
    
    
    clkdiv #(.div(20)) Divider(.clk(clk), .rst(rst), .en(en));
    
     
    fsm_init Oled_init(
            .clk(clk), 
            .rst(rst), 
            .en(init_en), 
            .sdo(init_sdo),
			.sclk(init_sclk),
			.dc(init_dc),
			.res(oled_res),
			.vbat(oled_vbat),
			.vdd(oled_vdd),
			.fin(init_done)
    );
     
     
	fsm_oper Oled_oper (
			.clk(clk),
			.rst(rst),
			.en(oper_en),
			.spi_fin(spi_fin),
			.dc(oper_dc),
			.spi_data(),
			.fin(oper_done)
	);


	assign oled_sdin = (curr_state == Init) ? init_sdo : data_sdo;
	assign oled_dc = (curr_state == Init) ? init_dc : oper_dc;

	assign init_en = (curr_state == Init) ? 1'b1 : 1'b0;
	assign oper_en = (curr_state == Oper) ? 1'b1 : 1'b0;


    always @* begin
        next_state = Init;
        case(curr_state)
            Idle: if(en) next_state = Init;
            Init: if(init_done) next_state = Oper;
            Oper: if(oper_done) next_state = Done;
            Done: next_state = Idle;
        endcase
    end


    always @(posedge clk, posedge rst) begin
        if(rst)  curr_state <= Idle;
        else     curr_state <= next_state;
    end     
    
     
endmodule
