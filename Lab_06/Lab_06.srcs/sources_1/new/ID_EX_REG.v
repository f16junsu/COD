`include "constants.v"
`include "opcodes.v"

module ID_EX_REG(
    input clk,
    input reset_n,
    input isFlush,

    // Blue WB Block Register
    input in_valid_inst,
    input in_MemtoReg,
    input in_RegWrite,
    input in_isLink,
    output reg out_valid_inst,
    output reg out_MemtoReg,
    output reg out_RegWrite,
    output reg out_isLink,

    // Blue MEM Block Register
    input in_MemRead,
    input in_MemWrite,
    input [1:0] in_PCSource,
    input in_BTBmiss,
    output reg out_MemRead,
    output reg out_MemWrite,
    output reg [1:0] out_PCSource,
    output reg out_BTBmiss,

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
            out_valid_inst <= 0;
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_isLink <= 0;
            out_MemRead <= 0;
            out_MemWrite <= 0;
            out_PCSource <= 2'b00;
            out_BTBmiss <= 0;
            out_outputenable <= 0;
            out_RegDest <= 2'b00;
            out_ALUop <= `OP_ID;
            out_ALUSource <= 2'b00;
            out_PC <= 0;
            out_instruction <= `IDLE;
            out_RF_read_data1 <= 0;
            out_RF_read_data2 <= 0;
        end
        else if (isFlush) begin
            out_valid_inst <= 0;
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_isLink <= 0;
            out_MemRead <= 0;
            out_MemWrite <= 0;
            out_PCSource <= 2'b00;
            out_BTBmiss <= 0;
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
            out_valid_inst <= in_valid_inst;
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_isLink <= in_isLink;
            out_MemRead <= in_MemRead;
            out_MemWrite <= in_MemWrite;
            out_PCSource <= in_PCSource;
            out_BTBmiss <= in_BTBmiss;
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