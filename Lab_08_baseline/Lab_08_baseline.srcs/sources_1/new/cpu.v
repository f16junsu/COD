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
        inout [`LINE_SIZE-1:0] i_data,

	// Data memory interface
        output d_readM,
        output d_writeM,
        output [`WORD_SIZE-1:0] d_address,
        inout [`LINE_SIZE-1:0] d_data,

        output [`WORD_SIZE-1:0] num_inst,
        output [`WORD_SIZE-1:0] output_port,
        output is_halted,

        input dma_begin,
        input dma_end,
        input BR,
        output reg BG,
        output cmd
);
        wire use_rs;
        wire use_rt;
        wire isHLT_to_ID_EX;
        wire valid_inst_to_ID_EX;
        wire MemtoReg_to_ID_EX;
        wire RegWrite_to_ID_EX;
        wire isLink_to_ID_EX;
        wire MemRead_to_ID_EX;
        wire MemWrite_to_ID_EX;
        wire [1:0] PCSource_to_ID_EX;
        wire isBranchorJmp_to_ID_EX;
        wire outputenable_to_ID_EX;
        wire [1:0] RegDest_to_ID_EX;
        wire [3:0] ALUop_to_ID_EX;
        wire [1:0] ALUSource_to_ID_EX;

        wire [`WORD_SIZE-1:0] instruction;
        wire stall_PC;
        // wires for cache
        wire ic_readC;
        wire ic_ready;
        wire [`WORD_SIZE-1:0] ic_address;
        wire [`WORD_SIZE-1:0] ic_data;

        wire dc_readC;
        wire dc_writeC;
        wire [`WORD_SIZE-1:0] dc_address;
        wire dc_ready;
        wire dc_w_done;
        wire [`WORD_SIZE-1:0] dc_data;



        Instruction_Cache ic_unit (.clk(Clk),
                                   .reset_n(Reset_N),
                                   .isStall(stall_PC),
                                   .readC(ic_readC),
                                   .address(ic_address),
                                   .ready(ic_ready),
                                   .data(ic_data),
                                   .line_from_mem(i_data),
                                   .readM(i_readM),
                                   .address_to_mem(i_address));

        Data_Cache dc_unit (.clk(Clk),
                            .reset_n(Reset_N),
                            .BG(BG),
                            .readC(dc_readC),
                            .writeC(dc_writeC),
                            .address(dc_address),
                            .ready(dc_ready),
                            .w_done(dc_w_done),
                            .data(dc_data),
                            .line_mem(d_data),
                            .readM(d_readM),
                            .writeM(d_writeM),
                            .address_to_mem(d_address));

        Control control_unit (.instruction(instruction),
                              .isHLT(isHLT_to_ID_EX),
                              .use_rs(use_rs),
                              .use_rt(use_rt),
                              .valid_inst(valid_inst_to_ID_EX),
                              .MemtoReg(MemtoReg_to_ID_EX),
                              .RegWrite(RegWrite_to_ID_EX),
                              .isLink(isLink_to_ID_EX),
                              .MemRead(MemRead_to_ID_EX),
                              .MemWrite(MemWrite_to_ID_EX),
                              .PCSource(PCSource_to_ID_EX),
                              .isBranchorJmp(isBranchorJmp_to_ID_EX),
                              .outputenable(outputenable_to_ID_EX),
                              .RegDest(RegDest_to_ID_EX),
                              .ALUop(ALUop_to_ID_EX),
                              .ALUSource(ALUSource_to_ID_EX));

        Datapath datapath_unit (.clk(Clk),
                                .reset_n(Reset_N),
                                .use_rs(use_rs),
                                .use_rt(use_rt),
                                .isHLT_to_ID_EX(isHLT_to_ID_EX),
                                .valid_inst_to_ID_EX(valid_inst_to_ID_EX),
                                .MemtoReg_to_ID_EX(MemtoReg_to_ID_EX),
                                .RegWrite_to_ID_EX(RegWrite_to_ID_EX),
                                .isLink_to_ID_EX(isLink_to_ID_EX),
                                .MemRead_to_ID_EX(MemRead_to_ID_EX),
                                .MemWrite_to_ID_EX(MemWrite_to_ID_EX),
                                .PCSource_to_ID_EX(PCSource_to_ID_EX),
                                .isBranchorJmp_to_ID_EX(isBranchorJmp_to_ID_EX),
                                .outputenable_to_ID_EX(outputenable_to_ID_EX),
                                .RegDest_to_ID_EX(RegDest_to_ID_EX),
                                .ALUop_to_ID_EX(ALUop_to_ID_EX),
                                .ALUSource_to_ID_EX(ALUSource_to_ID_EX),
                                .BG(BG),
                                .instruction(instruction),
                                .stall_PC_to_ic(stall_PC),
                                .ic_ready(ic_ready),
                                .i_readM(ic_readC),
                                .i_writeM(i_writeM),
                                .i_address(ic_address),
                                .i_data(ic_data),
                                .dc_ready(dc_ready),
                                .dc_w_done(dc_w_done),
                                .d_readM_from_cache(d_readM),
                                .d_readM(dc_readC),
                                .d_writeM(dc_writeC),
                                .d_address(dc_address),
                                .d_data(dc_data),
                                .num_inst(num_inst),
                                .output_port(output_port),
                                .is_halted(is_halted));

        assign cmd = dma_begin;

        always @(negedge Reset_N) begin
                BG <= 1'b0;
        end
        always @(posedge Clk) begin
                if (!d_readM && !d_writeM && BR) BG <= 1'b1;
        end
        always @(negedge BR) begin
                BG <= 1'b0;
        end
endmodule
