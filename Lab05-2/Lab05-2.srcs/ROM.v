`include "opcodes.v"
`include "constants.v"

`define STATE_IF 000
`define STATE_ID 001
`define STATE_EX 010
`define STATE_MEM 011
`define STATE_WB 100
`define STATE_ZERO 111 // state when reset

module ROM(
    input [2:0] state,
    input [3:0] opcode,
    input [5:0] funct,

    output isHLT,
    output outputenable,
    output PCWritecond,
    output PCWrite,
    output IorD,
    output MemRead,
    output MemWrite,

    output IRWrite,
    output [1:0] RegDest,
    output MemtoReg,
    output RegWrite,

    output ALUSourceA,
    output [1:0] ALUSourceB,
    output [1:0] PCSource,

    output reg [3:0] AluControl,
    output reg [2:0] nstate
    );
    reg [15:0] control_signals;

    assign isHLT = (control_signals === 16'b0) ? 1 : 0;
    assign outputenable = control_signals[15];
    assign PCWritecond = control_signals[14];
    assign PCWrite = control_signals[13];
    assign IorD = control_signals[12];
    assign MemRead = control_signals[11];
    assign MemWrite = control_signals[10];

    assign IRWrite = control_signals[9];
    assign RegDest = control_signals[8:7];
    assign MemtoReg = control_signals[6];
    assign RegWrite = control_signals[5];

    assign ALUSourceA = control_signals[4];
    assign ALUSourceB = control_signals[3:2];
    assign PCSource = control_signals[1:0];

    always @(*) begin
        case (state)
            `STATE_ZERO: begin
                control_signals = 16'b0010000xxx0xxxxx;
                AluControl = `OP_ZERO;
                nstate = `STATE_IF;
                //{control_signals, AluControl, nstate} = {16'b0010000xxx0xxxxx, `OP_ZERO, `STATE_IF};
            end
            `STATE_IF: {control_signals, AluControl, nstate} = {16'b0010101xxx000110, `OP_ADD, `STATE_ID};
            `STATE_ID: begin
                case (opcode)
                    `OPCODE_JMP: {control_signals, AluControl, nstate} = {16'b001x000xx00xxx00, `OP_ZERO, `STATE_IF};
                    `OPCODE_JAL: {control_signals, AluControl, nstate} = {16'b001x0001001xxx00, `OP_ZERO, `STATE_IF};
                    `OPCODE_RTYPE: begin
                        case (funct)
                            `FUNC_WWD: {control_signals, AluControl, nstate} = {16'b100x000xxx0xxxxx, `OP_ZERO, `STATE_IF};
                            `FUNC_JPR: {control_signals, AluControl, nstate} = {16'b001x000xx00xxx01, `OP_ZERO, `STATE_IF};
                            `FUNC_JRL: {control_signals, AluControl, nstate} = {16'b001x0001001xxx01, `OP_ZERO, `STATE_IF};
                            `FUNC_HLT: {control_signals, AluControl, nstate} = {16'b0000000000000000,
                            `OP_ZERO, `STATE_ID};
                            default: {control_signals, AluControl, nstate} = {16'b000x000xxx0xxxxx, `OP_ZERO, `STATE_EX};
                        endcase
                    end
                    `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b000x000xx00010xx, `OP_BRAADD, `STATE_EX};
                    default: {control_signals, AluControl, nstate} = {16'b000x000xxx0xxxxx, `OP_ZERO, `STATE_EX};
                endcase
            end
            `STATE_EX: begin
                case (opcode)
                    `OPCODE_BNE: {control_signals, AluControl, nstate} = {16'b010x000xx0010011, `OP_BNE, `STATE_IF};
                    `OPCODE_BEQ: {control_signals, AluControl, nstate} = {16'b010x000xx0010011, `OP_BEQ, `STATE_IF};
                    `OPCODE_BGZ: {control_signals, AluControl, nstate} = {16'b010x000xx001xx11, `OP_BGZ, `STATE_IF};
                    `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b010x000xx001xx11, `OP_BLZ, `STATE_IF};
                    `OPCODE_RTYPE: {control_signals, AluControl, nstate} = {16'b000x000xx00100xx, opcode[3:0], `STATE_WB};
                    `OPCODE_ADI: {control_signals, AluControl, nstate} = {16'b000x000xx00110xx, `OP_ADD, `STATE_WB};
                    `OPCODE_ORI: {control_signals, AluControl, nstate} = {16'b000x000xx00110xx, `OP_OR, `STATE_WB};
                    `OPCODE_LHI: {control_signals, AluControl, nstate} = {16'b000x000xx00xxxxx, `OP_LHI, `STATE_WB};
                    default: {control_signals, AluControl, nstate} = {16'b000x000xx00110xx, `OP_ADD, `STATE_MEM};
                endcase
            end
            `STATE_MEM: begin
                case (opcode)
                    `OPCODE_SWD: {control_signals, AluControl, nstate} = {16'b0001010xx00xxxxx, `OP_ID, `STATE_IF};
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b0001100xxx0xxxxx, `OP_ID, `STATE_WB};
                endcase
            end
            `STATE_WB: begin
                case (opcode)
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b000x0001011xxxxx, `OP_ID, `STATE_IF};
                    default: {control_signals, AluControl, nstate} = {16'b000x0000101xxxxx, `OP_ID, `STATE_IF};
                endcase
            end
        endcase
    end
endmodule
