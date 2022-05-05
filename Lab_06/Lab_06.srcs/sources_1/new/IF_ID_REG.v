`include "constants.v"

module IF_ID_REG(
    input clk,
    input reset_n,
    input isStall,

    input [`WORD_SIZE-1:0] in_PC,
    input [`WORD_SIZE-1:0] in_instruction,
    input in_BTBmiss,

    output reg [`WORD_SIZE-1:0] out_PC,
    output reg [`WORD_SIZE-1:0] out_instruction,
    output reg out_BTBmiss
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_PC <= `IDLE; // have to substitute to IDLE address
            out_instruction <= `IDLE; // IDLE instruction
            out_BTBmiss <= 0;
        end
        else if (isStall) begin // When stall disable latch
            out_PC <= out_PC;
            out_instruction <= out_instruction;
            out_BTBmiss <= out_BTBmiss;
        end
        else begin
            out_PC <= in_PC;
            out_instruction <= in_instruction;
            out_BTBmiss <= in_BTBmiss;
        end
    end
endmodule