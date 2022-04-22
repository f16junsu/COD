`timescale 1ns / 100ps

// R-type operations
`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
`define	OP_AND	4'b0010
`define	OP_OR	4'b0011
`define	OP_NOT	4'b0100
`define	OP_TCP	4'b0101
`define	OP_SHL	4'b0110
`define	OP_SHR	4'b0111

// LHI operation
`define	OP_LHI	4'b1000

// branch condition operations
`define	OP_BNE	4'b1001
`define	OP_BEQ	4'b1010
`define	OP_BGZ	4'b1011
`define	OP_BLZ	4'b1100

// etc
`define	OP_BRAADD	4'b1101 // PC + 1 + imm
`define	OP_ID	4'b1110
`define	OP_ZERO	4'b1111

module ALU(
    input [15:0] A,
    input [15:0] B,
    input [3:0] OP,
    input Cin,

    output reg [15:0] C,
    output reg Cout,
    output reg branch_cond
    );
    always @(*) begin
        case (OP)
            `OP_ADD: {Cout, C, branch_cond} = {A + B + Cin, 0};
            `OP_SUB: {Cout, C, branch_cond} = {A - (B + Cin), 0};
            `OP_AND: {Cout, C, branch_cond} = {0, A & B, 0};
            `OP_OR: {Cout, C, branch_cond} = {0, A | B, 0};
            `OP_NOT: {Cout, C, branch_cond} = {0, ~A, 0};
            `OP_TCP: {Cout, C, branch_cond} = {0, ~A + 1, 0};
            `OP_SHL: {Cout, C, branch_cond} = {0, A << 1, 0};
            `OP_SHR: begin
                Cout = 0;
                C = A >> 1;
                C[15] = C[14];
                branch_cond = 0;
            end
            `OP_LHI: {Cout, C, branch_cond} = {0, C << 8, 0};
            `OP_BNE: {Cout, C, branch_cond} = {0, 0, A != B};
            `OP_BEQ: {Cout, C, branch_cond} = {0, 0, A == B};
            `OP_BGZ: {Cout, C, branch_cond} = {0, 0, A > 0};
            `OP_BLZ: {Cout, C, branch_cond} = {0, 0, A < B};
            `OP_BRAADD: {Cout, C, branch_cond} = {0, A + 1 + B, 0};
            `OP_ID: {Cout, C, branch_cond} = {0, A, 0}; // just for filling
            `OP_ZERO: {Cout, C, branch_cond} = {0, 0, 0}; // just for filling
        endcase
     end
endmodule
