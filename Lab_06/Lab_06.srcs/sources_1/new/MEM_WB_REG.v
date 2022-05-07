`include "constants.v"
`include "opcodes.v"

module MEM_WB_REG(
    input clk,
    input reset_n,

    // Blue WB Block Register
    input in_isHLT,
    input in_valid_inst,
    input in_MemtoReg,
    input in_RegWrite,
    input in_isLink,
    input in_outputenable,
    output reg out_isHLT,
    output reg out_valid_inst,
    output reg out_MemtoReg,
    output reg out_RegWrite,
    output reg out_isLink,
    output reg out_outputenable,

    input [`WORD_SIZE-1:0] in_Memread_data,
    input [`WORD_SIZE-1:0] in_ALU_result,
    input [`WORD_SIZE-1:0] in_PC_plus_1,
    input [`WORD_SIZE-1:0] in_RF_read_data1,
    input [1:0] in_RFwrite_destination,
    output reg [`WORD_SIZE-1:0] out_MemRead_data,
    output reg [`WORD_SIZE-1:0] out_ALU_result,
    output reg [`WORD_SIZE-1:0] out_PC_plus_1,
    output reg [`WORD_SIZE-1:0] out_RF_read_data1,
    output reg [1:0] out_RFwrite_destination
    );
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            out_isHLT <= 0;
            out_valid_inst <= 0;
            out_MemtoReg <= 0;
            out_RegWrite <= 0;
            out_isLink <= 0;
            out_outputenable <= 0;
            out_MemRead_data <= 0;
            out_ALU_result <= 0;
            out_PC_plus_1 <= 0;
            out_RF_read_data1 <= 0;
            out_RFwrite_destination <= 0;
        end
        else begin
            out_isHLT <= in_isHLT;
            out_valid_inst <= in_valid_inst;
            out_MemtoReg <= in_MemtoReg;
            out_RegWrite <= in_RegWrite;
            out_isLink <= in_isLink;
            out_outputenable <= in_outputenable;
            out_MemRead_data <= in_Memread_data;
            out_ALU_result <= in_ALU_result;
            out_PC_plus_1 <= in_PC_plus_1;
            out_RF_read_data1 <= in_RF_read_data1;
            out_RFwrite_destination <= in_RFwrite_destination;
        end
    end
endmodule
