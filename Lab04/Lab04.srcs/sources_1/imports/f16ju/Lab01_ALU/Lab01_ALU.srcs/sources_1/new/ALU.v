`timescale 1ns / 100ps

`define	OP_ADD	4'b0000
`define	OP_SUB	4'b0001
//  Bitwise Boolean operation
`define	OP_ID		4'b0010
`define	OP_NAND	4'b0011
`define	OP_NOR	4'b0100
`define	OP_XNOR	4'b0101
`define	OP_NOT	4'b0110
`define	OP_AND	4'b0111
`define	OP_OR		4'b1000
`define	OP_XOR	4'b1001
// Shifting
`define	OP_LRS	4'b1010
`define	OP_ARS	4'b1011
`define	OP_RR		4'b1100
`define	OP_LLS	4'b1101
`define	OP_ALS	4'b1110
`define	OP_RL		4'b1111

module ALU(
    input [15:0] A,
    input [15:0] B,
    input [3:0] OP,
    input Cin,
    output reg [15:0] C,
    output reg Cout
    );
    always @(*) begin
        case (OP)
            `OP_ADD: {Cout, C} = A + B + Cin;
            `OP_SUB: {Cout, C} = A - (B + Cin);
            `OP_ID: {Cout, C} = {0, A};
            `OP_NAND: {Cout, C} = {0, ~(A & B)};
            `OP_NOR: {Cout, C} = {0, ~(A | B)};
            `OP_XNOR: {Cout, C} = {0, A ~^ B};
            `OP_NOT: {Cout, C} = {0, ~A};
            `OP_AND: {Cout, C} = {0, A & B};
            `OP_OR: {Cout, C} = {0, A | B};
            `OP_XOR: {Cout, C} = {0, A ^ B};
            `OP_LRS: {Cout, C} = {0, A >> 1};
            `OP_ARS:
                begin
                    C = A >> 1;
                    C[15] = C[14];
                    Cout = 0;
                end
            `OP_RR:
                begin
                    C = A >> 1;
                    C[15] = A[0];
                    Cout = 0;
                end
            `OP_LLS: {Cout, C} = {0, A << 1};
            `OP_ALS: {Cout, C} = {0, A <<< 1};
            `OP_RL:
                begin
                    C = A << 1;
                    C[0] = A[15];
                    Cout = 0;
                end
            default: {Cout, C} = 0;
         endcase
     end
endmodule
