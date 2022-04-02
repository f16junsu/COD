// Control module

// `include "opcodes.v"
`define OPCODE_RTYPE 4'd15
`define WORD_SIZE 16
//ALU opcodes
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
//  Bitwise Boolean operation
`define	OP_ID	4'b0010
`define	OP_NAND	4'b0011
`define	OP_NOR	4'b0100
`define	OP_XNOR	4'b0101
`define	OP_NOT	4'b0110
`define	OP_AND	4'b0111
`define	OP_OR	4'b1000
`define	OP_XOR	4'b1001
// Shifting
`define	OP_LRS	4'b1010
`define	OP_ARS	4'b1011
`define	OP_RR	4'b1100
`define	OP_LLS	4'b1101
`define	OP_ALS	4'b1110
`define	OP_RL	4'b1111
`define DCARE   4'bxxxx

`define FUNC_ADD 6'd0
`define FUNC_SUB 6'd1
`define FUNC_AND 6'd2
`define FUNC_ORR 6'd3
`define FUNC_NOT 6'd4
`define FUNC_TCP 6'd5
`define FUNC_SHL 6'd6
`define FUNC_SHR 6'd7
`define FUNC_WWD 6'd28

`define OPCODE_ADI 4'd4
`define OPCODE_ORI 4'd5
`define OPCODE_LHI 4'd6
`define OPCODE_LWD 4'd7
`define OPCODE_SWD 4'd8
`define OPCODE_BNE 4'd0
`define OPCODE_BEQ 4'd1
`define OPCODE_BGZ 4'd2
`define OPCODE_BLZ 4'd3
`define OPCODE_JMP 4'd9
`define OPCODE_JAL 4'd10

module Control (
  input [`WORD_SIZE-1:0] instruction,

  output isLHI,
  output isJump,
  output regDest,
  output writeReg,
  output isItype,
  output enableOutput,
  output reg [3:0] aluControl
);
    assign isLHI = controlsignal[5];
    assign isJump = controlsignal[4];
    assign regDest = controlsignal[3];
    assign writeReg = controlsignal[2];
    assign isItype = controlsignal[1];
    assign enableOutput = controlsignal[0];
    reg [5:0] controlsignal; // internal register for control signals

    always @(*)begin
        case (instruction[15:12])
            `OPCODE_RTYPE: begin
                case (instruction[5:0])
                    `FUNC_ADD: {aluControl, controlsignal} = {`OP_ADD, 6'b001100}; // ADD
                    `FUNC_WWD: {aluControl, controlsignal} = {`DCARE, 6'b00x001}; // WWD
                    default: {aluControl, controlsignal} = {4'b0000, 6'b000000};
                endcase
                end
            `OPCODE_ADI: {aluControl, controlsignal} = {`OP_ADD, 6'b000110}; // ADI
            `OPCODE_LHI: {aluControl, controlsignal} = {`DCARE, 6'b100110}; // LHI
            `OPCODE_JMP: {aluControl, controlsignal} = {`DCARE, 6'b01x0x0}; // JMP
            default: {aluControl, controlsignal} = {4'b0000, 6'b000000};
        endcase
    end
endmodule