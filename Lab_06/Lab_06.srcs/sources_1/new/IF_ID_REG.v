`include "constants.v"

module IF_ID_REG(
    input clk,
    input reset_n,
    input isStall,

    input [`WORD_SIZE-1:0] in_PC,
    input [`WORD_SIZE-1:0] in_instruction,
    input in_BTBmiss_gen,

    output reg [`WORD_SIZE-1:0] out_PC,
    output reg [`WORD_SIZE-1:0] out_instruction,
    output reg out_BTBmiss_gen
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_PC <= `IDLE; // have to substitute to IDLE address
            out_instruction <= `IDLE; // IDLE instruction
            out_BTBmiss_gen <= 0;
        end
        else if (isStall) begin // When stall disable latch
            out_PC <= out_PC;
            out_instruction <= out_instruction;
            out_BTBmiss_gen <= out_BTBmiss_gen;
        end
        else begin
            out_PC <= in_PC;
            out_instruction <= in_instruction;
            out_BTBmiss_gen <= in_BTBmiss_gen;
        end
    end
endmodule