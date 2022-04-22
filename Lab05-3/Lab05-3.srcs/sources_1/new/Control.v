`include "opcodes.v"
`include "constants.v"

`define STATE_IF 3'b000
`define STATE_ID 3'b001
`define STATE_EX 3'b010
`define STATE_MEM 3'b011
`define STATE_WB 3'b100
`define STATE_ZERO 3'b111

module Control(
    input [15:0] instruction,
    input clk,
    input reset_n,

    output isHLT,
    output outputenable,
    output PCWritecond,
    output PCWrite,
    output IorD,
    output MemRead,
    output MemWrite,

    output IRWrite,
    output [1:0] RegDest,
    output MemtoReg,
    output RegWrite,

    output ALUSourceA,
    output [1:0] ALUSourceB,
    output [1:0] PCSource,

    output [3:0] AluControl,
    output reg [`WORD_SIZE-1:0] num_inst
    );
    reg [2:0] uPC;
    wire [2:0] nextuPC;

    ROM rom (.state(uPC),
            .opcode(instruction[15:12]),
            .funct(instruction[5:0]),
            .isHLT(isHLT),
            .outputenable(outputenable),
            .PCWritecond(PCWritecond),
            .PCWrite(PCWrite),
            .IorD(IorD),
            .MemRead(MemRead),
            .MemWrite(MemWrite),
            .IRWrite(IRWrite),
            .RegDest(RegDest),
            .MemtoReg(MemtoReg),
            .RegWrite(RegWrite),
            .ALUSourceA(ALUSourceA),
            .ALUSourceB(ALUSourceB),
            .PCSource(PCSource),
            .AluControl(AluControl),
            .nstate(nextuPC)
            );

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            uPC <= `STATE_ZERO;
            num_inst <= 0;
        end
        else begin
            uPC <= nextuPC;
            if (nextuPC == `STATE_IF) num_inst <= num_inst + 1;
        end
    end
endmodule
