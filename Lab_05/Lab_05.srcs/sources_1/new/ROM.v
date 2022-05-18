`include "opcodes.v"
`include "constants.v"

`define STATE_IF 3'b000
`define STATE_ID 3'b001
`define STATE_EX 3'b010
`define STATE_MEM 3'b011
`define STATE_WB 3'b100
`define STATE_ZERO 3'b111 // state when reset

// ROM file for control signals
// based on uPC(state) and opcode, funct
// control signals are combinational logically determined
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
    reg [15:0] control_signals; // for aliasing

    assign isHLT = control_signals === 16'b0; // asserted when all control_signal bits are 0(`FUNC_HLT)
    assign outputenable = control_signals[15]; // asserted when WWD
    assign PCWritecond = control_signals[14]; // asserted when branch
    assign PCWrite = control_signals[13]; // asserted when PC should be written
    assign IorD = control_signals[12]; // 0: Intruction, 1: Data
    assign MemRead = control_signals[11];
    assign MemWrite = control_signals[10];

    assign IRWrite = control_signals[9]; // asserted when IR should be written
    assign RegDest = control_signals[8:7]; // 00: IR[9:8], 01: IR[7:6], 10: $2
    assign MemtoReg = control_signals[6]; // 0: ALUout, 1: MDR
    assign RegWrite = control_signals[5];

    assign ALUSourceA = control_signals[4];
    assign ALUSourceB = control_signals[3:2];
    assign PCSource = control_signals[1:0];

    always @(*) begin
        case (state)
            `STATE_ZERO: {control_signals, AluControl, nstate} = {16'b0010000000000000, `OP_ZERO, `STATE_IF};
            `STATE_IF: {control_signals, AluControl, nstate} = {16'b0010101000000110, `OP_ADD, `STATE_ID}; // IR <= Mem[PC], PC <= PC + 1
            `STATE_ID: begin
                case (opcode)
                    `OPCODE_JMP: {control_signals, AluControl, nstate} = {16'b0010000000000000, `OP_ZERO, `STATE_IF}; // PC <= PC[15:12], IR[11:0]
                    `OPCODE_JAL: {control_signals, AluControl, nstate} = {16'b0010000100100000, `OP_ZERO, `STATE_IF}; // PC <= PC[15:12], IR[11:0], $2 <= PC + 1
                    `OPCODE_RTYPE: begin
                        case (funct)
                            `FUNC_WWD: {control_signals, AluControl, nstate} = {16'b1000000000000000, `OP_ZERO, `STATE_IF}; // outputport <= RF[$rs]
                            `FUNC_JPR: {control_signals, AluControl, nstate} = {16'b0010000000000001, `OP_ZERO, `STATE_IF}; // PC <= RF[$rs]
                            `FUNC_JRL: {control_signals, AluControl, nstate} = {16'b0010000100100001, `OP_ZERO, `STATE_IF}; // PC <= RF[$rs], $2 <= PC + 1
                            `FUNC_HLT: {control_signals, AluControl, nstate} = {16'b0000000000000000, `OP_ZERO, `STATE_ID}; // program halt
                            default: {control_signals, AluControl, nstate} = {16'b0000000000000011, `OP_ZERO, `STATE_EX}; // A <= RF[$rs], B <= RF[$rt]
                        endcase
                    end
                    `OPCODE_BNE, `OPCODE_BEQ, `OPCODE_BGZ, `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b0000000000001000, `OP_BRAADD, `STATE_EX}; // ALUout <= PC + signextended(IR[7:0]) (as PC is already been PC + 1)
                    default: {control_signals, AluControl, nstate} = {16'b0000000000000011, `OP_ZERO, `STATE_EX}; // A <= RF[$rs], B <= RF[$rt]
                endcase
            end
            `STATE_EX: begin
                case (opcode)
                    `OPCODE_BNE: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BNE, `STATE_IF}; // PC <= ALUout when condition met
                    `OPCODE_BEQ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BEQ, `STATE_IF}; // PC <= ALUout when condition met
                    `OPCODE_BGZ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BGZ, `STATE_IF}; // PC <= ALUout when condition met
                    `OPCODE_BLZ: {control_signals, AluControl, nstate} = {16'b0100000000010011, `OP_BLZ, `STATE_IF}; // PC <= ALUout when condition met
                    `OPCODE_RTYPE: {control_signals, AluControl, nstate} = {16'b0000000000010000, funct[3:0], `STATE_WB}; // ALUout <= alu_result
                    `OPCODE_ADI: {control_signals, AluControl, nstate} = {16'b0000000000011000, `OP_ADD, `STATE_WB}; // ALUout <= alu_result
                    `OPCODE_ORI: {control_signals, AluControl, nstate} = {16'b0000000000011100, `OP_OR, `STATE_WB}; // ALUout <= alu_result
                    `OPCODE_LHI: {control_signals, AluControl, nstate} = {16'b0000000000001100, `OP_LHI, `STATE_WB}; // ALUout <= alu_result
                    default: {control_signals, AluControl, nstate} = {16'b0000000000011000, `OP_ADD, `STATE_MEM}; // ALUout <= A + signextended(IR[7:0])
                endcase
            end
            `STATE_MEM: begin
                case (opcode)
                    `OPCODE_SWD: {control_signals, AluControl, nstate} = {16'b0001010000000000, `OP_ID, `STATE_IF}; // MEM[ALUout] <= B
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b0001100000000000, `OP_ID, `STATE_WB}; // MDR <= MEM[ALUout]
                endcase
            end
            `STATE_WB: begin
                case (opcode)
                    `OPCODE_LWD: {control_signals, AluControl, nstate} = {16'b0000000001100000, `OP_ID, `STATE_IF}; // RF[$rt] <= MDR
                    `OPCODE_ADI, `OPCODE_ORI, `OPCODE_LHI: {control_signals, AluControl, nstate} ={16'b0000000000100000, `OP_ID, `STATE_IF}; // RF[$rt] <= ALUout
                    default: {control_signals, AluControl, nstate} = {16'b0000000010100000, `OP_ID, `STATE_IF}; // RF[$rd] <= ALUout
                endcase
            end
        endcase
    end
endmodule