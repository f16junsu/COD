`include "constants.v"
`include "opcodes.v"

module MEM_WB_REG(
    input clk,
    input reset_n,

    // Blue WB Block Register
    input in_MemtoReg,
    input in_RegWrite,
    output reg out_MemtoReg,
    output reg out_RegWrite,

    input [`WORD_SIZE-1:0] in_Memread_data,
    input [`WORD_SIZE-1:0] in_ALU_result,
    output reg [`WORD_SIZE-1:0] out_MemRead_data,
    output reg [`WORD_SIZE-1:0] out_ALU_result
    );
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_MemRead_data <= 0;
            out_ALU_result <= 0;
        end
        else begin
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_MemRead_data <= in_Memread_data;
            out_ALU_result <= in_ALU_result;
        end
    end
endmodule
