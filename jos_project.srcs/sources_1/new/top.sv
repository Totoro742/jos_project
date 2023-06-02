`timescale 1ns / 1ps

typedef enum {Idle, Init, Oper, Done} top_state_t;

// enable nie uzywane
module top( input clk, rst, output wire [7:0] leds,
            output oled_dc, output oled_res, output oled_sclk, output oled_sdin, output oled_vbat, output oled_vdd,
            output cs, sclk, input enable, input datain0, input datain1);
    
    localparam bits = 16, ndr = 5;
    
    logic clr_ctrl, clr;
    logic [7:0] data2trans;
    wire [bits-1:0] data_rec;
    wire example_en;
    reg [bits-1:0] sh_reg;
    reg spi_fin, oled_fin;
    logic oled_en, oper_done;
    top_state_t curr_state, next_state;
    
    wire init_en;
	wire init_done;
	wire init_cs;
	wire init_sdo;
	wire init_sclk;
	wire init_dc;
	
	wire example_cs;
	wire example_sdo;
	wire example_sclk;
	wire example_dc;
	wire example_done;
    wire sclk_adc;
    wire sclk_oled;
    wire cs_oled;
    spi #(.bits(bits), .mode(0)) adc_master (.clk(clk), .rst(rst), .en(en), .miso(datain0), .clr_ctrl(), .data2trans(),
    .clr(), .ss(cs), .sclk(sclk), .mosi(), .data_rec(data_rec), .fin());
    
     spi #(.bits(bits), .mode(0)) oled_slave (.clk(clk), .rst(rst), .en(en), .miso(), .clr_ctrl(), .data2trans(oled_data),
    .clr(), .ss(cs_oled), .sclk(oled_sclk), .mosi(example_sdo), .data_rec(), .fin(spi_fin));
   
    
    assign leds=data_rec[9:2];
    
    clkdiv #(.div(20)) divider(.clk(clk), .rst(rst), .en(en));
    
     
    fsm_init oled_init(.clk(clk), .rst(rst), .en(init_en), .sdo(init_sdo),
			.sclk(init_sclk),
			.dc(init_dc),
			.res(oled_res),
			.vbat(oled_vbat),
			.vdd(oled_vdd),
			.fin(init_done));
     
     /*module fsm_oper(input clk, input rst, input en, output fin, output logic dc,
                input spi_fin, output logic spi_en, output logic [7:0] oled_data);*/
     
	fsm_oper Operation (
			.clk(clk),
			.rst(rst),
			.en(example_en),
			.spi_fin(spi_fin),
			.dc(example_dc),
			.fin(oper_done)
	);


	//MUXes to indicate which outputs are routed out depending on which block is enabled
	//assign CS = (current_state == OledInitialize) ? init_cs : example_cs;
	assign oled_sdin = (curr_state == Init) ? init_sdo : example_sdo;
	//assign oled_sclk = (curr_state == Init) ? init_sclk : example_sclk;
	assign oled_dc = (curr_state == Init) ? init_dc : example_dc;
	//END output MUXes

	
	//MUXes that enable blocks when in the proper states
	assign init_en = (curr_state == Init) ? 1'b1 : 1'b0;
	assign example_en = (curr_state == Oper) ? 1'b1 : 1'b0;
	//END enable MUXes


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
     
    
     
endmodule
