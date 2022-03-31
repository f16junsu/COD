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
    output [15:0] C,
    output Cout
    );
   
    reg [15:0] C;
    reg Cout;
    
    always @(*) begin
        Cout = 0;
        case (OP)
            `OP_ADD: {Cout, C} = A + B + Cin;
            `OP_SUB: {Cout, C} = A - (B + Cin);
            `OP_ID: C = A;
            `OP_NAND: C = ~(A & B);
            `OP_NOR: C = ~(A | B);
            `OP_XNOR: C = A ~^ B;
            `OP_NOT: C = ~A;
            `OP_AND: C = A & B;
            `OP_OR: C = A | B;
            `OP_XOR: C = A ^ B;
            `OP_LRS: C = A >> 1;
            `OP_ARS: 
                begin
                    C = A >> 1;
                    C[15] = C[14];
                end
            `OP_RR:
                begin
                    C = A >> 1;
                    C[15] = A[0];
                end
            `OP_LLS: C = A << 1;
            `OP_ALS: C = A <<< 1;
            `OP_RL:
                begin
                    C = A << 1;
                    C[0] = A[15];
                end
         endcase
     end
endmodule
