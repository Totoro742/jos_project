`timescale 1ns / 1ps


module shreg #(parameter size = 8) (
    input clk, rst, en, push,
    output [size-1:0] out_reg
    );
    
    logic [size-1:0] shr;    
        
    always @(posedge clk, posedge rst)
        if(rst)
            shr <= {size {1'b0}};
        else if(en)
            shr <= { shr[size-2:0], push };
    
    assign out_reg = shr;
       
endmodule
