`timescale 1ns / 1ps

// po odliczeniu czasu - jeden impuls
module counter #(parameter cnt_max=2)(
    input clk, rst, en,
    output out_reg);
     
    localparam cnt_max_bit = $clog2(cnt_max);
    logic [cnt_max_bit-1:0] cnt;
        
    always @(posedge clk, posedge rst)
        if(rst)
            cnt <= { cnt_max_bit {1'b0}};
        else if (en)
            if(cnt >= cnt_max)
                cnt <= {cnt_max_bit {1'b0}};
            else
                cnt <= cnt + 1'b1;

    assign out_reg = (cnt == cnt_max-1);

endmodule
