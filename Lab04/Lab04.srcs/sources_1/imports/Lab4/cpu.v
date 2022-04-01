///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author:
// Description:

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
  output reg [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);
  // ... fill in the rest of the code
    wire isJump, regDest, writeReg, isItype, enableOutput;
    wire [`WORD_SIZE-1:0] instruction;
    wire [3:0] aluControl;

    Datapath datapath (isJump, regDest, writeReg, isItype, enableOutput, aluControl, instruction,
                       readM, address, data, inputReady, reset_n, clk);
    Control control (instruction, isJump, regDest, writereg, isItype, enableOutput, aluControl);

    always @(posedge clk) begin
        if (!reset_n) begin
          num_inst <= 0;
        end
        else begin
          num_inst <= num_inst + 1;
        end
    end
endmodule
//////////////////////////////////////////////////////////////////////////