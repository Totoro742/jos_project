`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineers: Ryan Kim
//				  Josh Sackos
// 
// Create Date:    13:43:40 06/13/2012 
// Module Name:    Delay - Behavioral 
// Project Name:   PmodOled Demo
// Tool versions:  ISE 14.1
// Description:    Creates a delay of DELAY_MS ms
//
// Revision: 1.0
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
module Delay #(parameter moduloN = 100_000, nbits = 12) 
    (input CLK, RST, DELAY_EN, 
    input [nbits-1:0] DELAY_MS,
    output DELAY_FIN);
    
    localparam Idle=2'b00, Hold=2'b01, Done=2'b11;
    localparam size_div = $clog2(moduloN);
	reg [1:0] current_state, next_state;   // Signal for state machine
	reg [size_div-1:0] clk_counter;                // Counts up on every rising edge of CLK
	reg [nbits-1:0] ms_counter;                 // Counts up when clk_counter = 100,000


	// ===========================================================================
	// 										Implementation
	// ===========================================================================
	assign DELAY_FIN = (current_state == Done && DELAY_EN == 1'b1) ? 1'b1 : 1'b0;
	
	//  State Machine
	always @(posedge CLK) 
	// When RST is asserted switch to idle (synchronous)
	if(RST) 
	   current_state <= Idle;
	else
	   current_state <=	next_state; 
	   
	always @* begin
	next_state = Idle;
	case(current_state)
		Idle :
			// Start delay on DELAY_EN
			if(DELAY_EN) 
				next_state = Hold;
			else
				next_state = Idle;
							
	   Hold : 
            // Stay until DELAY_MS has occureddc
			if(ms_counter == DELAY_MS) 
				next_state = Done;
			else
                next_state = Hold;
							
		Done : 
			// Wait until DELAY_EN is deasserted to go to IDLE
			if(~DELAY_EN) 
                next_state = Idle;
			else
                next_state = Hold;
							
			default : next_state = Idle;
							
	endcase
	end
	//  End State Machine


	// Creates ms_counter that counts at 1KHz
	always @(posedge CLK) 
	if(RST) 
	   ms_counter <= {nbits{1'b0}};
	else 
		if(current_state == Hold) begin
			if(clk_counter == moduloN) 
				ms_counter <= ms_counter + 1'b1;
			end				// increments at 1KHz
		else 
			ms_counter <= {nbits{1'b0}};

	// CLK_DIV
	always @(posedge CLK) 
	if(RST) 
	   clk_counter <= {size_div{1'b0}};
	else 
		if(current_state == Hold) 
			if(clk_counter == moduloN) 		// 100,000    17'b11000011010100000
				clk_counter <= {size_div{1'b0}};
			else 
				clk_counter <= clk_counter + 1'b1;
		else 												// If not in the hold state reset counters
			clk_counter <= {size_div{1'b0}};
endmodule
