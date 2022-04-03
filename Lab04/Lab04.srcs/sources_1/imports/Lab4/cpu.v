///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: 2018-19206 Minjae Kim
// Description: Lab04 Single-Cycle CPU

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

// INCLUDE files
`include "opcodes.v"    // "opcode.v" consists of "define" statements for
                        // the opcodes and function codes for all instructions

// MODULE DECLARATION
module cpu (
  output readM,                       // read from memory
  output [`WORD_SIZE-1:0] address,    // current address for data
  inout [`WORD_SIZE-1:0] data,        // data being input or output
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal
  // for debuging/testing purpose
  output reg [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
  output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);

    // wire declarations
    wire isLHI, isJump, regDest, writeReg, isItype, enableOutput; // wire used to wire datapath and control
    wire [`WORD_SIZE-1:0] instruction; // wire used to wire datapath and control
    wire [3:0] aluControl; // wire used to wire datapath and control

    Datapath datapath (.isLHI(isLHI),
                       .isJump(isJump),
                       .regDest(regDest),
                       .writeReg(writeReg),
                       .isItype(isItype),
                       .enableOutput(enableOutput),
                       .aluControl(aluControl),
                       .inputReady(inputReady),
                       .reset_n(reset_n),
                       .clk(clk),
                       .instruction(instruction),
                       .readM(readM),
                       .address(address),
                       .output_port(output_port),
                       .data(data));
    Control control (.instruction(instruction),
                     .isLHI(isLHI),
                     .isJump(isJump),
                     .regDest(regDest),
                     .writeReg(writeReg),
                     .isItype(isItype),
                     .enableOutput(enableOutput),
                     .aluControl(aluControl));

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
          num_inst <= 0;
        end
        else begin
          num_inst <= num_inst + 1;
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////