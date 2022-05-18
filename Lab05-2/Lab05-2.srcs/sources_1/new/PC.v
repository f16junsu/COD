module PC(
    input enablePCLatch,
    input [`WORD_SIZE-1:0] nextPC,
    input reset_n,
    input clk,

    output reg [`WORD_SIZE-1:0] currentPC
    );
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) currentPC <= -1;
        else if (enablePCLatch) currentPC <= nextPC;
        else currentPC <= currentPC;
    end
endmodule
