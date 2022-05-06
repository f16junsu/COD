`include "opcodes.v"
`include "constants.v"

module Hazard(
    input [1:0] rs_ID,
    input [1:0] rt_ID,
    input [1:0] dest_EX,
    input [1:0] dest_MEM,
    input use_rs,
    input use_rt,
    input RegWrite_EX,
    input RegWrite_MEM,

    input branch_mispredicted,

    output reg BTB_forward_PC,
    output reg stall_PC,
    output reg stall_IF_ID,
    output reg flush_IF_ID,
    output reg flush_ID_EX,
    output reg flush_EX_MEM
    );
    wire hazard_by_RAW;
    wire hazard_by_MISTAKEN_BRANCH;

    assign hazard_by_RAW = ((rs_ID == dest_EX) &&
                           use_rs && RegWrite_EX) |
                          ((rs_ID == dest_MEM) &&
                           use_rs && RegWrite_MEM) |
                          ((rt_ID == dest_EX) &&
                           use_rt && RegWrite_EX) |
                          ((rt_ID == dest_MEM) &&
                           use_rt && RegWrite_MEM);
    assign hazard_by_MISTAKEN_BRANCH = branch_mispredicted;

    always @(*) begin
        if (hazard_by_MISTAKEN_BRANCH) begin
            BTB_forward_PC = 1;
            stall_PC = 0;
            stall_IF_ID = 0;
            flush_IF_ID = 1;
            flush_ID_EX = 1;
            flush_EX_MEM = 1;
        end
        else if (hazard_by_RAW) begin
            BTB_forward_PC = 0;
            stall_PC = 1;
            stall_IF_ID = 1;
            flush_IF_ID = 1;
            flush_ID_EX = 0;
            flush_EX_MEM = 0;
        end
        else begin
            BTB_forward_PC = 0;
            stall_PC = 0;
            stall_IF_ID = 0;
            flush_IF_ID = 0;
            flush_ID_EX = 0;
            flush_EX_MEM = 0;
        end
    end
endmodule
