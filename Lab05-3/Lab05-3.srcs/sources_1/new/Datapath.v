`include "opcodes.v"
`include "constants.v"

module Datapath(
    input outputenable,
    input PCWritecond,
    input PCWrite,
    input IorD,
    input MemRead,
    input MemWrite,

    input IRWrite,
    input [1:0] RegDest,
    input MemtoReg,
    input RegWrite,

    input ALUSourceA,
    input [1:0] ALUSourceB,
    input [1:0] PCSource,

    input [3:0] AluControl,


    output reg readM, // read from memory
    output writeM, // write to memory
    output [`WORD_SIZE-1:0] address, // current address for data
    inout [`WORD_SIZE-1:0] data, // data being input or output
    input inputReady, // indicates that data is ready from the input port
    input reset_n, // active-low RESET signal
    input clk, // clock signal

    // for debuging/testing purpose
    output reg [`WORD_SIZE-1:0] output_port, // this will be used for a "WWD" instruction
    output [`WORD_SIZE-1:0] instruction
    );
    wire [`WORD_SIZE-1:0] currentPC; // currentPC
    wire [`WORD_SIZE-1:0] muxed_memory_address;
    wire [`WORD_SIZE-1:0] muxed_write_dest; // RF write destination
    wire [`WORD_SIZE-1:0] muxed_write_data; // RF write data
    wire [`WORD_SIZE-1:0] concat_pcsource; // {PC[[15:12]], IR[11:0]}
    wire [`WORD_SIZE-1:0] ALUsource1; // ALUSource A
    wire [`WORD_SIZE-1:0] ALUsource2; // ALUSource B
    wire [`WORD_SIZE-1:0] sign_extended_offset;
    wire [`WORD_SIZE-1:0] zero_extended_offset;
    wire [`WORD_SIZE-1:0] nextPC; // PC waiting for latching
    wire [`WORD_SIZE-1:0] RF_read_result1; // RF read1 before latched in A
    wire [`WORD_SIZE-1:0] RF_read_result2; // RF read2 before latched in B
    wire [`WORD_SIZE-1:0] ALU_result; // ALU_result before latched in ALUout
    wire enablePCLatch;
    wire branch_cond; // wiring between Datapath and Control
    wire alu_overflow; // just in case for alu overflow

    reg [`WORD_SIZE-1:0] received_data;
    reg [`WORD_SIZE-1:0] IR;
    reg [`WORD_SIZE-1:0] MDR;
    reg [`WORD_SIZE-1:0] A;
    reg [`WORD_SIZE-1:0] B;
    reg [`WORD_SIZE-1:0] ALUout;

    assign muxed_memory_address = IorD ? ALUout : currentPC;
    assign muxed_write_dest = (RegDest == 2'b00) ? IR[9:8]:
                              (RegDest == 2'b01) ? IR[7:6]:
                              2'b10;
    assign muxed_write_data = MemtoReg ? MDR : ALUout;
    assign concat_pcsource = {currentPC[15:12], IR[11:0]};
    assign sign_extended_offset = {{8{IR[7]}}, IR[7:0]};
    assign zero_extended_offset = {{8{0}}, IR[7:0]};
    assign ALUsource1 = ALUSourceA ? A : currentPC;
    assign ALUsource2 = (ALUSourceB == 2'b00) ? B:
                        (ALUSourceB == 2'b01) ? 1:
                        (ALUSourceB == 2'b10) ? sign_extended_offset:
                        zero_extended_offset;
    assign nextPC = (PCSource == 2'b00) ? concat_pcsource:
                    (PCSource == 2'b01) ? RF_read_result1:
                    (PCSource == 2'b10) ? ALU_result:
                    ALUout;
    assign enablePCLatch = PCWrite | (PCWritecond & branch_cond);
    assign address = muxed_memory_address;
    assign instruction = IR;

    // wiring modules
    PC pc_unit (.enablePCLatch(enablePCLatch),
                .nextPC(nextPC),
                .reset_n(reset_n),
                .clk(clk),
                .currentPC(currentPC));

    RF rf_unit (.addr1(IR[11:10]),
                .addr2(IR[9:8]),
                .addr3(muxed_write_dest),
                .data3(muxed_write_data),
                .write(RegWrite),
                .clk(clk),
                .reset_n(reset_n),
                .data1(RF_read_result1),
                .data2(RF_read_result2));

    ALU alu_unit (.A(ALUsource1),
                  .B(ALUsource2),
                  .OP(AluControl),
                  .Cin(0),
                  .C(ALU_result),
                  .Cout(alu_overflow),
                  .branch_cond(branch_cond));

    // memory read
    always @(posedge MemRead or posedge inputReady) begin
        if (inputReady) begin
            received_data <= data;
            readM <= 0;
        end
        else readM <= 1;
    end

    // memory write
    assign data = MemWrite ? B : 16'bz;
    assign writeM = MemWrite;

    // latching output
    always @(*) begin
        output_port <= outputenable ? RF_read_result1 : output_port;
    end
    // latching registers
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            IR <= 0;
            MDR <= 0;
            A <= 0;
            B <= 0;
            ALUout <= 0;
        end
        else if (outputenable) begin
            MDR <= received_data;
            A <= RF_read_result1;
            B <= RF_read_result2;
            ALUout <= ALU_result;
            output_port <= RF_read_result1;
        end
        else if (IRWrite) begin
            IR <= received_data;
            MDR <= received_data;
            A <= RF_read_result1;
            B <= RF_read_result2;
            ALUout <= ALU_result;
        end
        else begin
            MDR <= received_data;
            A <= RF_read_result1;
            B <= RF_read_result2;
            ALUout <= ALU_result;
        end
    end

endmodule
