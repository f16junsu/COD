`include "constants.v"
`include "opcodes.v"

module Datapath(
    input clk,
    input reset_n,

    // receive signals from Control
    input use_rs,
    input use_rt,
    // Blue WB Block Register
    input isHLT_to_ID_EX,
    input valid_inst_to_ID_EX,
    input MemtoReg_to_ID_EX,
    input RegWrite_to_ID_EX,
    input isLink_to_ID_EX,
    // Blue MEM Block Register
    input MemRead_to_ID_EX,
    input MemWrite_to_ID_EX,
    input [1:0] PCSource_to_ID_EX,
    input isBranchorJmp_to_ID_EX,
    // Blue EX Block Register
    input outputenable_to_ID_EX,
    input [1:0] RegDest_to_ID_EX,
    input [3:0] ALUop_to_ID_EX,
    input [1:0] ALUSource_to_ID_EX,

    input BG,
    output [`WORD_SIZE-1:0] instruction,
    output stall_PC_to_ic,

	// Instruction memory interface
    input ic_ready,
    output i_readM,
    output i_writeM,
    output [`WORD_SIZE-1:0] i_address,
    inout [`WORD_SIZE-1:0] i_data,

	// Data memory interface
    input dc_ready,
    input dc_w_done,
    output d_readM,
    output d_writeM,
    output [`WORD_SIZE-1:0] d_address,
    inout [`WORD_SIZE-1:0] d_data,

    output reg [`WORD_SIZE-1:0] num_inst,
    output reg [`WORD_SIZE-1:0] output_port,
    output is_halted
    );
    wire [`WORD_SIZE-1:0] nextPC; // PC from BTB
    wire [`WORD_SIZE-1:0] currentPC; // PC from PC unit
    wire [`WORD_SIZE-1:0] PC_to_ID_EX; // PC from IF_ID Register
    wire [`WORD_SIZE-1:0] RF_read_data1; // Read data1 from RF in ID stage
    wire [`WORD_SIZE-1:0] RF_read_data2; // Read data2 from RF in ID stage
    wire [`WORD_SIZE-1:0] PC_from_ID_EX; // PC used in EX stage
    wire [`WORD_SIZE-1:0] PC_plus_1; // PC + 1 in EX stage
    wire [`WORD_SIZE-1:0] PC_branch_target; // PC + 1 + sign-extend(imm) in EX stage
    wire [`WORD_SIZE-1:0] PC_j_target; // PC[15:12],inst[11:0] in EX stage
    wire [`WORD_SIZE-1:0] PC_jr_target; // $rs in EX stage
    wire [`WORD_SIZE-1:0] RF_read_data1_from_ID_EX; // Read data1 from RF in EX stage
    wire [`WORD_SIZE-1:0] RF_read_data2_from_ID_EX; // Read data2 from RF in EX stage
    wire [`WORD_SIZE-1:0] instruction_to_EX_MEM; // instruction from ID_EX in EX stage
    wire [1:0] rw_destination_to_EX_MEM; // register write destination in EX stage
    wire [`WORD_SIZE-1:0] ALU_result_to_EX_MEM; // ALU result in EX stage
    wire ALU_overflow; // just in case for ALU overflow
    wire branch_cond_to_EX_MEM; // branch_cond to EX_MEM
    wire [`WORD_SIZE-1:0] ALU_SourceB; // ALU SourceB in EX stage
    wire [`WORD_SIZE-1:0] sign_extended_imm; // sign-extend(imm)
    wire [`WORD_SIZE-1:0] zero_extended_imm; // zero-extend(imm)
    wire [`WORD_SIZE-1:0] update_addr; // index in BTB for table update(PC in MEM stage)
    wire [`WORD_SIZE-1:0] PC_plus_1_from_EX_MEM; // PC + 1 in MEM stage
    wire [`WORD_SIZE-1:0] PC_branch_target_from_EX_MEM; // PC + 1 + sign-extend(imm) in MEM stage
    wire [`WORD_SIZE-1:0] PC_j_target_from_EX_MEM; // PC[15:12],inst[11:0] in MEM stage
    wire [`WORD_SIZE-1:0] PC_jr_target_from_EX_MEM; // $rs in MEM stage
    wire [`WORD_SIZE-1:0] muxed_with_branch_cond; // muxed between PC + 1 and PC + 1 + sign-extended(imm)
    wire [`WORD_SIZE-1:0] ALU_result_from_EX_MEM; // ALU result in MEM stage
    wire [1:0] rw_destination_to_MEM_WB; // register write destination in MEM stage
    wire [`WORD_SIZE-1:0] instruction_to_MEM_WB; // instruction in MEM stage
    wire [`WORD_SIZE-1:0] update_data; // PC source to update BTB
    wire [`WORD_SIZE-1:0] actual_next_PC; // actual next PC determined in MEM stage
    wire branch_mispredicted; // usable in MEM
    wire [`WORD_SIZE-1:0] Mem_read_data_from_MEM_WB; // memory data in WB stage
    wire [`WORD_SIZE-1:0] ALU_result_from_MEM_WB; // ALU result in WB stage
    wire [`WORD_SIZE-1:0] RF_read_data1_from_EX_MEM; // Read data1 in MEM stage
    wire [`WORD_SIZE-1:0] RF_read_data2_from_EX_MEM; // Read data2 in MEM stage
    wire [1:0] rw_destination; // register write destination in WB stage
    wire [`WORD_SIZE-1:0] mem_or_alu_muxed; // muxed from Memory data and ALU result
    wire [`WORD_SIZE-1:0] rw_data; // muxed from mem_or_alu_muxed and PC + 1
    wire [`WORD_SIZE-1:0] PC_plus_1_from_MEM_WB; // PC + 1 in WB stage
    wire [`WORD_SIZE-1:0] RF_read_data1_in_WB; // Read data1 in WB stage
    wire [`WORD_SIZE-1:0] predicted_nPC_to_ID_EX;
    wire [`WORD_SIZE-1:0] predicted_nPC_to_EX_MEM;
    wire [`WORD_SIZE-1:0] predicted_nPC; // predicted_nPC in MEM stage

    // regs for i_mem, d_mem status
    reg [1:0] i_status;
    reg [1:0] d_status;

    // wires for hazard
    wire i_mem_hazard;
    wire d_mem_hazard;
    wire BTB_forward_PC;
    wire stall_PC;
    wire stall_IF_ID;
    wire stall_ID_EX;
    wire stall_EX_MEM;
    wire flush_IF_ID;
    wire flush_ID_EX;
    wire flush_EX_MEM;
    wire flush_MEM_WB;

    wire [1:0] RegDest; // usable in EX
    wire [3:0] ALUop; // usable in EX
    wire [1:0] ALUSource; // usable in EX
    wire MemRead; // usable in MEM
    wire MemWrite; // usable in MEM
    wire [1:0] PCSource; // usable in MEM
    wire isBranchorJmp; // usable in MEM
    wire branch_cond; // usable in MEM
    wire valid_inst; // usable in WB
    wire MemtoReg; // usable in WB
    wire RegWrite; // usable in WB
    wire isLink; // usable in WB
    wire outputenable; // usable in WB
    wire isHLT; // usable in WB


    // wires to transfer signals from ID_EX to EX_MEM
    wire MemRead_to_EX_MEM;
    wire MemWrite_to_EX_MEM;
    wire [1:0] PCSource_to_EX_MEM;
    wire isBranchorJmp_to_EX_MEM;
    wire isHLT_to_EX_MEM;
    wire valid_inst_to_EX_MEM;
    wire MemtoReg_to_EX_MEM;
    wire RegWrite_to_EX_MEM;
    wire isLink_to_EX_MEM;
    wire outputenable_to_EX_MEM;

    // wires to transfer signals from EX_MEM to MEM_WB
    wire isHLT_to_MEM_WB;
    wire valid_inst_to_MEM_WB;
    wire MemtoReg_to_MEM_WB;
    wire RegWrite_to_MEM_WB;
    wire isLink_to_MEM_WB;
    wire outputenable_to_MEM_WB;

    Hazard hazard_unit (.rs_ID(instruction[11:10]),
                        .rt_ID(instruction[9:8]),
                        .dest_EX(rw_destination_to_EX_MEM),
                        .dest_MEM(rw_destination_to_MEM_WB),
                        .use_rs(use_rs),
                        .use_rt(use_rt),
                        .RegWrite_EX(RegWrite_to_EX_MEM),
                        .RegWrite_MEM(RegWrite_to_MEM_WB),
                        .valid_IF_ID(valid_inst_to_ID_EX),
                        .valid_ID_EX(valid_inst_to_EX_MEM),
                        .branch_mispredicted(branch_mispredicted),
                        .i_mem_hazard(i_mem_hazard),
                        .d_mem_hazard(d_mem_hazard),
                        .BTB_forward_PC(BTB_forward_PC),
                        .stall_PC(stall_PC),
                        .stall_IF_ID(stall_IF_ID),
                        .stall_ID_EX(stall_ID_EX),
                        .stall_EX_MEM(stall_EX_MEM),
                        .flush_IF_ID(flush_IF_ID),
                        .flush_ID_EX(flush_ID_EX),
                        .flush_EX_MEM(flush_EX_MEM),
                        .flush_MEM_WB(flush_MEM_WB));

    BTB btb_unit (.clk(clk),
                  .reset_n(reset_n),
                  .BTB_forward_PC(BTB_forward_PC),
                  .BTBupdate(isBranchorJmp),
                  .update_addr(update_addr),
                  .update_data(update_data),
                  .actual_next_PC(actual_next_PC),
                  .read_addr(currentPC),
                  .nextPC(nextPC));

    PC pc_unit (.clk(clk),
                .reset_n(reset_n),
                .isStall(stall_PC),
                .nextPC(nextPC),
                .currentPC(currentPC));

    IF_ID_REG if_id_reg_unit (.clk(clk),
                              .reset_n(reset_n),
                              .isStall(stall_IF_ID),
                              .isFlush(flush_IF_ID),
                              .in_PC(currentPC),
                              .in_predicted_nPC(nextPC),
                              .in_instruction(i_data),
                              .out_PC(PC_to_ID_EX),
                              .out_predicted_nPC(predicted_nPC_to_ID_EX),
                              .out_instruction(instruction));

    RF rf_unit (.addr1(instruction[11:10]),
                .addr2(instruction[9:8]),
                .addr3(rw_destination),
                .data3(rw_data),
                .write(RegWrite),
                .clk(clk),
                .reset_n(reset_n),
                .data1(RF_read_data1),
                .data2(RF_read_data2));

    ID_EX_REG id_ex_reg_unit (.clk(clk),
                              .reset_n(reset_n),
                              .isFlush(flush_ID_EX),
                              .isStall(stall_ID_EX),
                              .in_isHLT(isHLT_to_ID_EX),
                              .in_valid_inst(valid_inst_to_ID_EX),
                              .in_MemtoReg(MemtoReg_to_ID_EX),
                              .in_RegWrite(RegWrite_to_ID_EX),
                              .in_isLink(isLink_to_ID_EX),
                              .in_outputenable(outputenable_to_ID_EX),
                              .out_isHLT(isHLT_to_EX_MEM),
                              .out_valid_inst(valid_inst_to_EX_MEM),
                              .out_MemtoReg(MemtoReg_to_EX_MEM),
                              .out_RegWrite(RegWrite_to_EX_MEM),
                              .out_isLink(isLink_to_EX_MEM),
                              .out_outputenable(outputenable_to_EX_MEM),
                              .in_MemRead(MemRead_to_ID_EX),
                              .in_MemWrite(MemWrite_to_ID_EX),
                              .in_PCSource(PCSource_to_ID_EX),
                              .in_isBranchorJmp(isBranchorJmp_to_ID_EX),
                              .out_MemRead(MemRead_to_EX_MEM),
                              .out_MemWrite(MemWrite_to_EX_MEM),
                              .out_PCSource(PCSource_to_EX_MEM),
                              .out_isBranchorJmp(isBranchorJmp_to_EX_MEM),
                              .in_RegDest(RegDest_to_ID_EX),
                              .in_ALUop(ALUop_to_ID_EX),
                              .in_ALUSource(ALUSource_to_ID_EX),
                              .out_RegDest(RegDest),
                              .out_ALUop(ALUop),
                              .out_ALUSource(ALUSource),
                              .in_PC(PC_to_ID_EX),
                              .in_predicted_nPC(predicted_nPC_to_ID_EX),
                              .in_instruction(instruction),
                              .in_RF_read_data1(RF_read_data1),
                              .in_RF_read_data2(RF_read_data2),
                              .out_PC(PC_from_ID_EX),
                              .out_predicted_nPC(predicted_nPC_to_EX_MEM),
                              .out_instruction(instruction_to_EX_MEM),
                              .out_RF_read_data1(RF_read_data1_from_ID_EX),
                              .out_RF_read_data2(RF_read_data2_from_ID_EX));

    ALU alu_unit (.A(RF_read_data1_from_ID_EX),
                  .B(ALU_SourceB),
                  .OP(ALUop),
                  .Cin(0),
                  .C(ALU_result_to_EX_MEM),
                  .Cout(ALU_overflow),
                  .branch_cond(branch_cond_to_EX_MEM));

    EX_MEM_REG ex_mem_reg_unit (.clk(clk),
                                .reset_n(reset_n),
                                .isFlush(flush_EX_MEM),
                                .isStall(stall_EX_MEM),
                                .in_isHLT(isHLT_to_EX_MEM),
                                .in_valid_inst(valid_inst_to_EX_MEM),
                                .in_MemtoReg(MemtoReg_to_EX_MEM),
                                .in_RegWrite(RegWrite_to_EX_MEM),
                                .in_isLink(isLink_to_EX_MEM),
                                .in_outputenable(outputenable_to_EX_MEM),
                                .out_isHLT(isHLT_to_MEM_WB),
                                .out_valid_inst(valid_inst_to_MEM_WB),
                                .out_MemtoReg(MemtoReg_to_MEM_WB),
                                .out_RegWrite(RegWrite_to_MEM_WB),
                                .out_isLink(isLink_to_MEM_WB),
                                .out_outputenable(outputenable_to_MEM_WB),
                                .in_MemRead(MemRead_to_EX_MEM),
                                .in_MemWrite(MemWrite_to_EX_MEM),
                                .in_PCSource(PCSource_to_EX_MEM),
                                .in_isBranchorJmp(isBranchorJmp_to_EX_MEM),
                                .out_MemRead(MemRead),
                                .out_MemWrite(MemWrite),
                                .out_PCSource(PCSource),
                                .out_isBranchorJmp(isBranchorJmp),
                                .in_instruction(instruction_to_EX_MEM),
                                .in_PC_plus_1(PC_plus_1),
                                .in_predicted_nPC(predicted_nPC_to_EX_MEM),
                                .in_branch_target(PC_branch_target),
                                .in_J_target(PC_j_target),
                                .in_JR_target(PC_jr_target),
                                .in_ALU_result(ALU_result_to_EX_MEM),
                                .in_RFwrite_destination(rw_destination_to_EX_MEM),
                                .in_RF_read_data1(RF_read_data1_from_ID_EX),
                                .in_RF_read_data2(RF_read_data2_from_ID_EX),
                                .in_branch_cond(branch_cond_to_EX_MEM),
                                .out_instruction(instruction_to_MEM_WB),
                                .out_PC_plus_1(PC_plus_1_from_EX_MEM),
                                .out_predicted_nPC(predicted_nPC),
                                .out_branch_target(PC_branch_target_from_EX_MEM),
                                .out_J_target(PC_j_target_from_EX_MEM),
                                .out_JR_target(PC_jr_target_from_EX_MEM),
                                .out_ALU_result(ALU_result_from_EX_MEM),
                                .out_RFwrite_destination(rw_destination_to_MEM_WB),
                                .out_RF_read_data1(RF_read_data1_from_EX_MEM),
                                .out_RF_read_data2(RF_read_data2_from_EX_MEM),
                                .out_branch_cond(branch_cond));

    MEM_WB_REG mem_wb_reg_unit (.clk(clk),
                                .reset_n(reset_n),
                                .isFlush(flush_MEM_WB),
                                .in_isHLT(isHLT_to_MEM_WB),
                                .in_valid_inst(valid_inst_to_MEM_WB),
                                .in_MemtoReg(MemtoReg_to_MEM_WB),
                                .in_RegWrite(RegWrite_to_MEM_WB),
                                .in_isLink(isLink_to_MEM_WB),
                                .in_outputenable(outputenable_to_MEM_WB),
                                .out_isHLT(isHLT),
                                .out_valid_inst(valid_inst),
                                .out_MemtoReg(MemtoReg),
                                .out_RegWrite(RegWrite),
                                .out_isLink(isLink),
                                .out_outputenable(outputenable),
                                .in_Memread_data(d_data),
                                .in_ALU_result(ALU_result_from_EX_MEM),
                                .in_PC_plus_1(PC_plus_1_from_EX_MEM),
                                .in_RF_read_data1(RF_read_data1_from_EX_MEM),
                                .in_RFwrite_destination(rw_destination_to_MEM_WB),
                                .out_MemRead_data(Mem_read_data_from_MEM_WB),
                                .out_ALU_result(ALU_result_from_MEM_WB),
                                .out_PC_plus_1(PC_plus_1_from_MEM_WB),
                                .out_RF_read_data1(RF_read_data1_in_WB),
                                .out_RFwrite_destination(rw_destination));

    // hazard wires assignment
    assign i_mem_hazard = i_readM && !ic_ready;
    assign d_mem_hazard = (d_readM && !dc_ready) || (d_writeM && !dc_w_done) || ((d_readM || d_writeM) && BG);
    assign stall_PC_to_ic = stall_PC;

    // wire assignment
    assign i_readM = 1;
    assign i_writeM = 0;
    assign i_address = currentPC;
    assign d_readM = MemRead;
    assign d_writeM = MemWrite;
    assign d_address = ALU_result_from_EX_MEM;
    assign d_data = MemWrite ? RF_read_data2_from_EX_MEM : 16'bz;
    assign is_halted = isHLT;

    assign PC_plus_1 = PC_from_ID_EX + 1;
    assign PC_branch_target = PC_from_ID_EX + 1 + sign_extended_imm;
    assign PC_j_target = {PC_from_ID_EX[15:12], instruction_to_EX_MEM[11:0]};
    assign PC_jr_target = RF_read_data1_from_ID_EX;
    assign ALU_SourceB = (ALUSource == 2'b00) ? RF_read_data2_from_ID_EX:
                         (ALUSource == 2'b01) ? sign_extended_imm:
                         zero_extended_imm;
    assign sign_extended_imm = {{8{instruction_to_EX_MEM[7]}}, instruction_to_EX_MEM[7:0]};
    assign zero_extended_imm = {{8{1'b0}}, instruction_to_EX_MEM[7:0]};
    assign rw_destination_to_EX_MEM = (RegDest == 2'b00) ? instruction_to_EX_MEM[9:8]:
                                      (RegDest == 2'b01) ? instruction_to_EX_MEM[7:6]:
                                      2'b10;
    assign muxed_with_branch_cond = branch_cond ? PC_branch_target_from_EX_MEM :
                                    PC_plus_1_from_EX_MEM;
    assign update_data = (PCSource == 2'b00) ? PC_branch_target_from_EX_MEM:
                         (PCSource == 2'b01) ? PC_j_target_from_EX_MEM:
                         PC_jr_target_from_EX_MEM;
    assign actual_next_PC = (PCSource == 2'b00) ? muxed_with_branch_cond:
                            (PCSource == 2'b01) ? PC_j_target_from_EX_MEM:
                            PC_jr_target_from_EX_MEM;
    assign update_addr = PC_plus_1_from_EX_MEM - 1;
    assign branch_mispredicted = isBranchorJmp & (actual_next_PC != predicted_nPC);
    assign mem_or_alu_muxed = MemtoReg ? Mem_read_data_from_MEM_WB : ALU_result_from_MEM_WB;
    assign rw_data = isLink ? PC_plus_1_from_MEM_WB : mem_or_alu_muxed;

    // output port
    always @(posedge clk) begin
        if (outputenable) begin
            output_port <= RF_read_data1_in_WB;
        end
    end
    // num_inst count
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            num_inst <= 0;
        end
        else begin
            if (valid_inst) begin
                num_inst <= num_inst + 1;
            end
        end
    end
endmodule
