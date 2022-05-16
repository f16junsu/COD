`include "constants.v"

module IF_ID_REG(
    input clk,
    input reset_n,
    input isFlush,
    input isStall,

    input [`WORD_SIZE-1:0] in_PC,
    input [`WORD_SIZE-1:0] in_predicted_nPC,
    input [`WORD_SIZE-1:0] in_instruction,

    output reg [`WORD_SIZE-1:0] out_PC,
    output reg [`WORD_SIZE-1:0] out_predicted_nPC,
    output reg [`WORD_SIZE-1:0] out_instruction
);
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_PC <= `IDLE; // have to substitute to IDLE address
            out_predicted_nPC <= `IDLE;
            out_instruction <= `IDLE; // IDLE instruction
        end
        else if (isFlush) begin
            out_PC <= `IDLE; // have to substitute to IDLE address
            out_predicted_nPC <= `IDLE;
            out_instruction <= `IDLE; // IDLE instruction
        end
        else if (isStall) begin // When stall disable latch
            out_PC <= out_PC;
            out_predicted_nPC <= out_predicted_nPC;
            out_instruction <= out_instruction;
        end
        else begin
            out_PC <= in_PC;
            out_predicted_nPC <= in_predicted_nPC;
            out_instruction <= in_instruction;
        end
    end
endmodule