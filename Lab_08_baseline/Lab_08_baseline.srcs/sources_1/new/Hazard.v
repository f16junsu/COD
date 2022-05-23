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
    input valid_IF_ID,
    input valid_ID_EX,

    input branch_mispredicted,
    input i_mem_hazard,
    input d_mem_hazard,

    output reg BTB_forward_PC,
    output reg stall_PC,
    output reg stall_IF_ID,
    output reg stall_ID_EX,
    output reg stall_EX_MEM,
    output reg flush_IF_ID,
    output reg flush_ID_EX,
    output reg flush_EX_MEM,
    output reg flush_MEM_WB
    );
    wire [3:0] hazards;
    wire data_hazard;
    wire control_hazard;

    assign data_hazard = ((rs_ID == dest_EX) &&
                           use_rs && RegWrite_EX) |
                          ((rs_ID == dest_MEM) &&
                           use_rs && RegWrite_MEM) |
                          ((rt_ID == dest_EX) &&
                           use_rt && RegWrite_EX) |
                          ((rt_ID == dest_MEM) &&
                           use_rt && RegWrite_MEM);
    assign control_hazard = branch_mispredicted;

    assign hazards[3] = i_mem_hazard;
    assign hazards[2] = d_mem_hazard;
    assign hazards[1] = control_hazard;
    assign hazards[0] = data_hazard;

    always @(*) begin
        case (hazards)
            4'b0000: begin
                BTB_forward_PC = 0;
                stall_PC = 0;
                stall_IF_ID = 0;
                stall_ID_EX = 0;
                stall_EX_MEM = 0;
                flush_IF_ID = 0;
                flush_ID_EX = 0;
                flush_EX_MEM = 0;
                flush_MEM_WB = 0;
            end
            4'b0001: begin
                BTB_forward_PC = 0;
                stall_PC = 1;
                stall_IF_ID = 1;
                stall_ID_EX = 0;
                stall_EX_MEM = 0;
                flush_IF_ID = 0;
                flush_ID_EX = 1;
                flush_EX_MEM = 0;
                flush_MEM_WB = 0;
            end
            4'b0010, 4'b0011: begin
                BTB_forward_PC = 1;
                stall_PC = 0;
                stall_IF_ID = 0;
                stall_ID_EX = 0;
                stall_EX_MEM = 0;
                flush_IF_ID = 1;
                flush_ID_EX = 1;
                flush_EX_MEM = 1;
                flush_MEM_WB = 0;
            end
            4'b0100: begin
                if (valid_IF_ID && valid_ID_EX) begin
                    BTB_forward_PC = 0;
                    stall_PC = 1;
                    stall_IF_ID = 1;
                    stall_ID_EX = 1;
                    stall_EX_MEM = 1;
                    flush_IF_ID = 0;
                    flush_ID_EX = 0;
                    flush_EX_MEM = 0;
                    flush_MEM_WB = 1;
                end
                else if (valid_IF_ID && !valid_ID_EX) begin
                    BTB_forward_PC = 0;
                    stall_PC = 0;
                    stall_IF_ID = 0;
                    stall_ID_EX = 0;
                    stall_EX_MEM = 1;
                    flush_IF_ID = 0;
                    flush_ID_EX = 0;
                    flush_EX_MEM = 0;
                    flush_MEM_WB = 1;
                end
                else begin
                    BTB_forward_PC = 0;
                    stall_PC = 0;
                    stall_IF_ID = 0;
                    stall_ID_EX = 1;
                    stall_EX_MEM = 1;
                    flush_IF_ID = 0;
                    flush_ID_EX = 0;
                    flush_EX_MEM = 0;
                    flush_MEM_WB = 1;
                end
            end
            4'b1000: begin
                BTB_forward_PC = 0;
                stall_PC = 1;
                stall_IF_ID = 0;
                stall_ID_EX = 0;
                stall_EX_MEM = 0;
                flush_IF_ID = 1;
                flush_ID_EX = 0;
                flush_EX_MEM = 0;
                flush_MEM_WB = 0;
            end
            4'b1001: begin
                BTB_forward_PC = 0;
                stall_PC = 1;
                stall_IF_ID = 1;
                stall_ID_EX = 0;
                stall_EX_MEM = 0;
                flush_IF_ID = 0;
                flush_ID_EX = 1;
                flush_EX_MEM = 0;
                flush_MEM_WB = 0;
            end
            4'b1010, 4'b1011: begin
                BTB_forward_PC = 0;
                stall_PC = 1;
                stall_IF_ID = 1;
                stall_ID_EX = 1;
                stall_EX_MEM = 1;
                flush_IF_ID = 0;
                flush_ID_EX = 0;
                flush_EX_MEM = 0;
                flush_MEM_WB = 1;
            end
            4'b1100: begin
                if (valid_ID_EX) begin
                    BTB_forward_PC = 0;
                    stall_PC = 1;
                    stall_IF_ID = 1;
                    stall_ID_EX = 1;
                    stall_EX_MEM = 1;
                    flush_IF_ID = 0;
                    flush_ID_EX = 0;
                    flush_EX_MEM = 0;
                    flush_MEM_WB = 1;
                end
                else begin
                    BTB_forward_PC = 0;
                    stall_PC = 1;
                    stall_IF_ID = 0;
                    stall_ID_EX = 0;
                    stall_EX_MEM = 1;
                    flush_IF_ID = 1;
                    flush_ID_EX = 0;
                    flush_EX_MEM = 0;
                    flush_MEM_WB = 1;
                end
            end
            4'b1101: begin
                BTB_forward_PC = 0;
                stall_PC = 1;
                stall_IF_ID = 1;
                stall_ID_EX = 1;
                stall_EX_MEM = 1;
                flush_IF_ID = 0;
                flush_ID_EX = 0;
                flush_EX_MEM = 0;
                flush_MEM_WB = 1;
            end
        endcase
    end
endmodule
