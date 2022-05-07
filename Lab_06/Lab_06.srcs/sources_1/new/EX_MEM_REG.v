`include "constants.v"
`include "opcodes.v"

module EX_MEM_REG(
    input clk,
    input reset_n,
    input isFlush,

    // Blue WB Block Register
    input in_valid_inst,
    input in_MemtoReg,
    input in_RegWrite,
    input in_isLink,
    input in_outputenable,
    output reg out_valid_inst,
    output reg out_MemtoReg,
    output reg out_RegWrite,
    output reg out_isLink,
    output reg out_outputenable,

    // Blue MEM Block Register
    input in_MemRead,
    input in_MemWrite,
    input [1:0] in_PCSource,
    input in_isBranchorJmp,
    output reg out_MemRead,
    output reg out_MemWrite,
    output reg [1:0] out_PCSource,
    output reg out_isBranchorJmp,

    input [`WORD_SIZE-1:0] in_instruction,
    input [`WORD_SIZE-1:0] in_PC_plus_1,
    input [`WORD_SIZE-1:0] in_branch_target,
    input [`WORD_SIZE-1:0] in_J_target,
    input [`WORD_SIZE-1:0] in_JR_target,
    input [`WORD_SIZE-1:0] in_ALU_result,
    input [1:0] in_RFwrite_destination,
    input [`WORD_SIZE-1:0] in_RF_read_data1,
    input [`WORD_SIZE-1:0] in_RF_read_data2,
    input in_branch_cond,
    output reg [`WORD_SIZE-1:0] out_instruction,
    output reg [`WORD_SIZE-1:0] out_PC_plus_1,
    output reg [`WORD_SIZE-1:0] out_branch_target,
    output reg [`WORD_SIZE-1:0] out_J_target,
    output reg [`WORD_SIZE-1:0] out_JR_target,
    output reg [`WORD_SIZE-1:0] out_ALU_result,
    output reg [1:0] out_RFwrite_destination,
    output reg [`WORD_SIZE-1:0] out_RF_read_data1,
    output reg [`WORD_SIZE-1:0] out_RF_read_data2,
    output reg out_branch_cond
    );
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_valid_inst <= 0;
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_isLink <= 0;
            out_outputenable <= 0;
            out_MemRead <= 0;
            out_MemWrite <= 0;
            out_PCSource <= 2'b00;
            out_isBranchorJmp <= 0;
            out_instruction <= `IDLE;
            out_PC_plus_1 <= 0;
            out_branch_target <= 0;
            out_J_target <= 0;
            out_JR_target <= 0;
            out_ALU_result <= 0;
            out_RFwrite_destination <= 0;
            out_RF_read_data1 <= 0;
            out_RF_read_data2 <= 0;
            out_branch_cond <= 0;
        end
        else if (isFlush) begin
            out_valid_inst <= 0;
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_isLink <= 0;
            out_outputenable <= 0;
            out_MemRead <= 0;
            out_MemWrite <= 0;
            out_PCSource <= 2'b00;
            out_isBranchorJmp <= 0;
            out_instruction <= `IDLE;
            out_PC_plus_1 <= 0;
            out_branch_target <= 0;
            out_J_target <= 0;
            out_JR_target <= 0;
            out_ALU_result <= 0;
            out_RFwrite_destination <= 0;
            out_RF_read_data1 <= 0;
            out_RF_read_data2 <= 0;
            out_branch_cond <= 0;
        end
        else begin
            out_valid_inst <= in_valid_inst;
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_isLink <= in_isLink;
            out_outputenable <= in_outputenable;
            out_MemRead <= in_MemRead;
            out_MemWrite <= in_MemWrite;
            out_PCSource <= in_PCSource;
            out_isBranchorJmp <= in_isBranchorJmp;
            out_instruction <= in_instruction;
            out_PC_plus_1 <= in_PC_plus_1;
            out_branch_target <= in_branch_target;
            out_J_target <= in_J_target;
            out_JR_target <= in_JR_target;
            out_ALU_result <= in_ALU_result;
            out_RFwrite_destination <= in_RFwrite_destination;
            out_RF_read_data1 <= in_RF_read_data1;
            out_RF_read_data2 <= in_RF_read_data2;
            out_branch_cond <= in_branch_cond;
        end
    end
endmodule
