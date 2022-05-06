`timescale 1ns/1ns
`define WORD_SIZE 16    // data and address word size

`include "opcodes.v"

module cpu(
        input Clk,
        input Reset_N,

	// Instruction memory interface
        output i_readM,
        output i_writeM,
        output [`WORD_SIZE-1:0] i_address,
        inout [`WORD_SIZE-1:0] i_data,

	// Data memory interface
        output d_readM,
        output d_writeM,
        output [`WORD_SIZE-1:0] d_address,
        inout [`WORD_SIZE-1:0] d_data,

        output [`WORD_SIZE-1:0] num_inst,
        output [`WORD_SIZE-1:0] output_port,
        output is_halted
);
        wire isStall;
        wire isHLT;
        wire use_rs;
        wire use_rt;
        wire valid_inst_to_ID_EX;
        wire MemtoReg_to_ID_EX;
        wire RegWrite_to_ID_EX;
        wire isLink_to_ID_EX;
        wire MemRead_to_ID_EX;
        wire MemWrite_to_ID_EX;
        wire [1:0] PCSource_to_ID_EX;
        wire BTBmiss_to_ID_EX;
        wire outputenable_to_ID_EX;
        wire [1:0] RegDest_to_ID_EX;
        wire [3:0] ALUop_to_ID_EX;
        wire [1:0] ALUSource_to_ID_EX;

        wire should_stall;
        wire BTBmiss_gen_to_control;
        wire instruction;

        Control control_unit (.BTBmiss_gen(BTBmiss_gen_to_control),
                              .should_stall(should_stall),
                              .instruction(instruction),
                              .isStall(isStall),
                              .isHLT(isHLT),
                              .use_rs(use_rs),
                              .use_rt(use_rt),
                              .valid_inst(valid_inst_to_ID_EX),
                              .MemtoReg(MemtoReg_to_ID_EX),
                              .RegWrite(RegWrite_to_ID_EX),
                              .isLink(isLink_to_ID_EX),
                              .MemRead(MemRead_to_ID_EX),
                              .MemWrite(MemWrite_to_ID_EX),
                              .PCSource(PCSource_to_ID_EX),
                              .BTBmiss(BTBmiss_to_ID_EX),
                              .outputenable(outputenable_to_ID_EX),
                              .RegDest(RegDest_to_ID_EX),
                              .ALUop(ALUop_to_ID_EX),
                              .ALUSource(ALUSource_to_ID_EX));

        Datapath datapath_unit (.clk(Clk),
                                .reset_n(Reset_N),
                                .isStall(isStall),
                                .isHLT(isHLT),
                                .use_rs(use_rs),
                                .use_rt(use_rt),
                                .valid_inst_to_ID_EX(valid_inst_to_ID_EX),
                                .MemtoReg_to_ID_EX(MemtoReg_to_ID_EX),
                                .RegWrite_to_ID_EX(RegWrite_to_ID_EX),
                                .isLink_to_ID_EX(isLink_to_ID_EX),
                                .MemRead_to_ID_EX(MemRead_to_ID_EX),
                                .MemWrite_to_ID_EX(MemWrite_to_ID_EX),
                                .PCSource_to_ID_EX(PCSource_to_ID_EX),
                                .BTBmiss_to_ID_EX(BTBmiss_to_ID_EX),
                                .outputenable_to_ID_EX(outputenable_to_ID_EX),
                                .RegDest_to_ID_EX(RegDest_to_ID_EX),
                                .ALUop_to_ID_EX(ALUop_to_ID_EX),
                                .ALUSource_to_ID_EX(ALUSource_to_ID_EX),
                                .should_stall(should_stall),
                                .BTBmiss_gen_to_control(BTBmiss_gen_to_control),
                                .instruction(instruction),
                                .i_readM(i_readM),
                                .i_writeM(i_writeM),
                                .i_address(i_address),
                                .i_data(i_data),
                                .d_readM(d_readM),
                                .d_writeM(d_writeM),
                                .d_address(d_address),
                                .d_data(d_data),
                                .num_inst(num_inst),
                                .output_port(output_port),
                                .is_halted(is_halted));

endmodule
