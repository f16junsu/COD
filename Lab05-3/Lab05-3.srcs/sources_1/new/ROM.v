`include "opcodes.v"
`include "constants.v"

`define STATE_IF 3'b000
`define STATE_ID 3'b001
`define STATE_EX 3'b010
`define STATE_MEM 3'b011
`define STATE_WB 3'b100
`define STATE_ZERO 3'b111 // state when reset

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

    assign isHLT = control_signals === 16'b0;
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
            `STATE_ZERO: {control_signals, AluControl, nstate} = {16'b0010000000000000, `OP_ZERO, `STATE_IF};
            `STATE_IF: {control_signals, AluControl, nstate} = {16'b0010101000000110, `OP_ADD, `STATE_ID};
            `STATE_ID: begin
                case (opcode)
                    `OPCODE_JMP: {control_signals, AluControl, nstate} = {16'b0010000000000000, `OP_ZERO, `STATE_IF};
                    `OPCODE_JAL: {control_signals, AluControl, nstate} = {16'b0010000100100000, `OP_ZERO, `STATE_IF};
                    `OPCODE_RTYPE: begin
                        case (funct)
                            `FUNC_WWD: {control_signals, AluControl, nstate} = {16'b1000000000000000, `OP_ZERO, `STATE_IF};
                            `FUNC_JPR: {control_signals, AluControl, nstate} = {16'b0010000000000001, `OP_ZERO, `STATE_IF};
                            `FUNC_JRL: {control_signals, AluControl, nstate} = {16'b0010000100100001, `OP_ZERO, `STATE_IF};
                            `FUNC_HLT: {control_signals, AluControl, nstate} = {16'b0000000000000000, `OP_ZERO, `STATE_ID};
                            default: {control_signals, AluControl, nstate} = {16'b0000000000000011, `OP_ZERO, `STATE_EX};
                        endcase
                    end
                    `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b0000000000001000, `OP_BRAADD, `STATE_EX};
                    default: {control_signals, AluControl, nstate} = {16'b0000000000000011, `OP_ZERO, `STATE_EX};
                endcase
            end
            `STATE_EX: begin
                case (opcode)
                    `OPCODE_BNE: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BNE, `STATE_IF};
                    `OPCODE_BEQ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BEQ, `STATE_IF};
                    `OPCODE_BGZ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BGZ, `STATE_IF};
                    `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BLZ, `STATE_IF};
                    `OPCODE_RTYPE: {control_signals, AluControl, nstate} = {16'b0000000000010000, funct[3:0], `STATE_WB};
                    `OPCODE_ADI: {control_signals, AluControl, nstate} = {16'b0000000000011000, `OP_ADD, `STATE_WB};
                    `OPCODE_ORI: {control_signals, AluControl, nstate} = {16'b0000000000011100, `OP_OR, `STATE_WB};
                    `OPCODE_LHI: {control_signals, AluControl, nstate} = {16'b0000000000001100, `OP_LHI, `STATE_WB};
                    default: {control_signals, AluControl, nstate} = {16'b0000000000011000, `OP_ADD, `STATE_MEM};
                endcase
            end
            `STATE_MEM: begin
                case (opcode)
                    `OPCODE_SWD: {control_signals, AluControl, nstate} = {16'b0001010000000000, `OP_ID, `STATE_IF};
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b0001100000000000, `OP_ID, `STATE_WB};
                endcase
            end
            `STATE_WB: begin
                case (opcode)
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b0000000101100000, `OP_ID, `STATE_IF};
                    `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI: {control_signals, AluControl, nstate} ={16'b0000000000100000, `OP_ID, `STATE_IF};
                    default: {control_signals, AluControl, nstate} = {16'b0000000010100000, `OP_ID, `STATE_IF}; // R-type
                endcase
            end
        endcase
    end
endmodule
