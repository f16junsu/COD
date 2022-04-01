// Datapath module

`define WORD_SIZE 16

module Datapath (
  //receiving from control unit
  input isJump,
  input regDest,
  input writeReg,
  input isItype,
  input enableOutput,
  input [3:0] aluControl,

  // output for control unit
  output reg [`WORD_SIZE-1:0] instruction,
  //communicating with memory unit
  output reg readM,                       // read from memory
  output reg [`WORD_SIZE-1:0] address,    // current address for data
  inout [`WORD_SIZE-1:0] data,        // data being input or output
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk                          // clock signal
);

    // used for memory
    wire [`WORD_SIZE-1:0] currentPC;
    wire [`WORD_SIZE-1:0] nextPC;
    wire [1:0] write_register_muxed = regDest ? instruction[9:8] : instruction[7:6];
    wire [`WORD_SIZE-1:0] ALU_result;
    wire [`WORD_SIZE-1:0] RF_read_result1;
    wire [`WORD_SIZE-1:0] RF_read_result2;
    wire overflow;
    wire signed [`WORD_SIZE-1:0] sign_extended = $signed(instruction[7:0]);
    wire [`WORD_SIZE-1:0] alu_source2_muxed = isItype ? sign_extended : RF_read_result2;



    // wiring units
    PC pc_unit (nextPC, reset_n, clk, currentPC); // wiring PC unit
    RF rf_unit (instruction[11:10], instruction[9:8], write_register_muxed, ALU_result,
           writeReg, clk, reset_n, RF_read_result1, RF_read_result2); // wiring RF unit
    ALU alu_unit (RF_read_result1, RF_read_result2, aluControl, 1'b0, ALU_result, overflow); // wiring ALU unit

    assign nextPC = isJump ? {currentPC[15:12], instruction[11:0]} : currentPC + 1; // combinational logic for nextPC
    assign data = enableOutput ? RF_read_result1 : data;


    // instruction fetch
    always @(posedge clk) begin
      address = currentPC;
      readM = 1;
    end
    always @(posedge inputReady) begin
      instruction = data;
      readM = 0;
    end


endmodule