`include "constants.v"
`include "opcodes.v"

module ID_EX_REG(
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

    // Blue EX Block Register
    input in_outputenable,
    input [1:0] in_RegDest,
    input [3:0] in_ALUop,
    input [1:0] in_ALUSource,
    output reg out_outputenable,
    output reg [1:0] out_RegDest,
    output reg [3:0] out_ALUop,
    output reg [1:0] out_ALUSource,

    input [`WORD_SIZE-1:0] in_PC,
    input [`WORD_SIZE-1:0] in_instruction,
    input [`WORD_SIZE-1:0] in_RF_read_data1,
    input [`WORD_SIZE-1:0] in_RF_read_data2,
    output reg [`WORD_SIZE-1:0] out_PC,
    output reg [`WORD_SIZE-1:0] out_instruction,
    output reg [`WORD_SIZE-1:0] out_RF_read_data1,
    output reg [`WORD_SIZE-1:0] out_RF_read_data2
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
            out_outputenable <= 0;
            out_RegDest <= 2'b00;
            out_ALUop <= `OP_ID;
            out_ALUSource <= 2'b00;
            out_PC <= 0;
            out_instruction <= `IDLE;
            out_RF_read_data1 <= 0;
            out_RF_read_data2 <= 0;
        end
        else begin
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_MemRead <= in_MemRead;
            out_MemWrite <= in_MemWrite;
            out_isJR <= in_isJR;
            out_isBranch <= in_isBranch;
            out_PCLatch_MEM <= in_PCLatch_MEM;
            out_outputenable <= in_outputenable;
            out_RegDest <= in_RegDest;
            out_ALUop <= in_ALUop;
            out_ALUSource <= in_ALUSource;
            out_PC <= in_PC;
            out_instruction <= in_instruction;
            out_RF_read_data1 <= in_RF_read_data1;
            out_RF_read_data2 <= in_RF_read_data2;
        end
    end
endmodule