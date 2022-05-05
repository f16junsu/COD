`include "constants.v"

module PC(
    input clk,
    input reset_n,
    input isStall,
    input [`WORD_SIZE-1:0] nextPC,

    output reg [`WORD_SIZE-1:0] currentPC
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            currentPC <= 0;
        end
        else if (isStall) begin
            currentPC <= currentPC;
        end
        else begin
            currentPC <= nextPC;
        end
    end
endmodule