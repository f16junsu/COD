`include "constants.v"
`include "opcodes.v"

module EX_MEM_REG(
    input clk,
    input reset_n,

    // Blue WB Block Register
    input in_MemtoReg,
    input in_RegWrite,
    output reg out_MemtoReg,
    output reg out_RegWrite,

    // Blue MEM Block Register
    input in_MemRead,
    input in_MemWrite,
    input in_isJR,
    input in_isBranch,
    input in_PCLatch_MEM,
    output reg out_MemRead,
    output reg out_MemWrite,
    output reg out_isJR,
    output reg out_isBranch,
    output reg out_PCLatch_MEM,

    input [`WORD_SIZE-1:0] in_instruction,
    input [`WORD_SIZE-1:0] in_PC_plus_1,
    input [`WORD_SIZE-1:0] in_branch_target,
    input [`WORD_SIZE-1:0] in_J_target,
    input [`WORD_SIZE-1:0] in_JR_target,
    input [`WORD_SIZE-1:0] in_ALU_result,
    input [`WORD_SIZE-1:0] in_RFwrite_destination,
    input in_branch_cond,
    output reg [`WORD_SIZE-1:0] out_instruction,
    output reg [`WORD_SIZE-1:0] out_PC_plus_1,
    output reg [`WORD_SIZE-1:0] out_branch_target,
    output reg [`WORD_SIZE-1:0] out_J_target,
    output reg [`WORD_SIZE-1:0] out_JR_target,
    output reg [`WORD_SIZE-1:0] out_ALU_result,
    output reg [`WORD_SIZE-1:0] out_RFwrite_destination,
    output reg out_branch_cond
    );
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_MemRead <= 0;
            out_MemWrite <= 0;
            out_isJR <= 0;
            out_isBranch <= 0;
            out_PCLatch_MEM <= 0;
            out_instruction <= `IDLE;
            out_PC_plus_1 <= 1;
            out_branch_target <= 0;
            out_J_target <= 0;
            out_JR_target <= 0;
            out_ALU_result <= 0;
            out_RFwrite_destination <= 0;
            out_branch_cond <= 0;
        end
        else begin
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_MemRead <= in_MemRead;
            out_MemWrite <= in_MemWrite;
            out_isJR <= in_isJR;
            out_isBranch <= in_isBranch;
            out_PCLatch_MEM <= in_PCLatch_MEM;
            out_instruction <= in_instruction;
            out_PC_plus_1 <= in_PC_plus_1;
            out_branch_target <= in_branch_target;
            out_J_target <= in_J_target;
            out_JR_target <= in_JR_target;
            out_ALU_result <= in_ALU_result;
            out_RFwrite_destination <= in_RFwrite_destination;
            out_branch_cond <= in_branch_cond;
        end
    end
endmodule
