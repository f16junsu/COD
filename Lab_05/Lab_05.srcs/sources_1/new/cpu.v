`timescale 1ns/100ps

`include "opcodes.v"
`include "constants.v"

module cpu (
    output readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal

    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst, // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output is_halted // 1 if the cpu is halted
);
    // wires
    wire outputenable;
    wire PCWritecond;
    wire PCWrite;
    wire IorD;
    wire MemRead;
    wire MemWrite;

    wire IRWrite;
    wire [1:0] RegDest;
    wire MemtoReg;
    wire RegWrite;

    wire ALUSourceA;
    wire [1:0] ALUSourceB;
    wire [1:0] PCSource;
    wire [3:0] AluControl;

    wire [`WORD_SIZE-1:0] instruction;

    // wiring datapath unit and control unit
    Datapath datapath(.outputenable(outputenable),
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
                      .readM(readM),
                      .writeM(writeM),
                      .address(address),
                      .data(data),
                      .inputReady(inputReady),
                      .reset_n(reset_n),
                      .clk(clk),
                      .output_port(output_port),
                      .instruction(instruction));

    Control control(.instruction(instruction),
                    .clk(clk),
                    .reset_n(reset_n),
                    .isHLT(is_halted),
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
                    .num_inst(num_inst));
endmodule