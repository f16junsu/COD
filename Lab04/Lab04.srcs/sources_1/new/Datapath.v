// Datapath module

`define WORD_SIZE 16

module Datapath (
  //receiving from control unit
  input isLHI,
  input isJump,
  input regDest,
  input writeReg,
  input isItype,
  input enableOutput,
  input [3:0] aluControl,
  input inputReady,                   // indicates that data is ready from the input port
  input reset_n,                      // active-low RESET signal
  input clk,                          // clock signal

  // output for control unit
  output reg [`WORD_SIZE-1:0] instruction,
  //communicating with memory unit
  output reg readM,                       // read from memory
  output [`WORD_SIZE-1:0] address,      // current address for data
  output [`WORD_SIZE-1:0] output_port, // ouput_port for WWD
  inout [`WORD_SIZE-1:0] data        // data being input or output
);
    // declaration of wires
    // wire [`WORD_SIZE-1:0] currentPC;
    wire [`WORD_SIZE-1:0] nextPC; // wire used to wire pc_unit and pc_unit
    wire [1:0] write_register_muxed; // mux wire into write register
    wire [`WORD_SIZE-1:0] ALU_result; // wire used to wire rf_unit and alu_unit
    wire [`WORD_SIZE-1:0] RF_read_result1; // wire used to wire rf_unit and alu_unit
    wire [`WORD_SIZE-1:0] RF_read_result2; // wire used to deliver read register2
    wire overflow; // wire used if overflow of alu_unit occurs
    wire signed [`WORD_SIZE-1:0] sign_extended; // sign_extended LSB 8 bits of instruction
    wire [`WORD_SIZE-1:0] alu_source2_muxed; // alu_source2 muxed with RF_read_result2 and sign_extended
    wire [`WORD_SIZE-1:0] write_data_muxed;


    // wires assignment(combinational logic)
    assign nextPC = isJump ? {address[15:12], instruction[11:0]} : address + 1; // combinational logic for nextPC
    assign write_register_muxed = regDest ? instruction[7:6] : instruction[9:8];
    assign sign_extended = $signed(instruction[7:0]);
    assign alu_source2_muxed = isItype ? sign_extended : RF_read_result2;
    assign output_port = enableOutput ? RF_read_result1 : 16'bz;
    assign write_data_muxed = isLHI ? {instruction[7:0], 8'b0} : ALU_result;

    // wiring units
    PC pc_unit (.nextPC(nextPC), // wiring PC unit
                .reset_n(reset_n),
                .clk(clk),
                .currentPC(address));

    RF rf_unit (.addr1(instruction[11:10]), // wiring RF unit
                .addr2(instruction[9:8]),
                .addr3(write_register_muxed),
                .data3(write_data_muxed),
                .write(writeReg),
                .clk(clk),
                .reset_n(reset_n),
                .data1(RF_read_result1),
                .data2(RF_read_result2));

    ALU alu_unit (.A(RF_read_result1), // wiring ALU unit
                  .B(alu_source2_muxed),
                  .OP(aluControl),
                  .Cin(1'b0),
                  .C(ALU_result),
                  .Cout(overflow));

    // instruction fetch
    always @(posedge clk or negedge reset_n or posedge inputReady) begin
      if(!reset_n) begin
        instruction <= 0;
        readM <=0;
      end
      else if(inputReady) begin
        instruction <= data;
        readM <= 0;
      end
      else begin
        readM <= 1;
        //$display("%b, %b, %b, %b, %b, %b", isLHI, isJump, regDest, writeReg, isItype, enableOutput);
        $display("%b", instruction);
        // $display("%h", RF_read_result1);
      end
    end



endmodule