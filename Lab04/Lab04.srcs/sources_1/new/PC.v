// module PC
// update PC at clk posedge

`define WORD_SIZE 16

module PC (
  input [`WORD_SIZE-1:0] nextPC,
  input reset_n,
  input clk,

  output [`WORD_SIZE-1:0] currentPC
);
  reg [`WORD_SIZE-1:0] currentPC;

  always @(posedge clk) begin
    if (!reset_n) currentPC <= 0;
    else currentPC <= nextPC;
  end
endmodule
