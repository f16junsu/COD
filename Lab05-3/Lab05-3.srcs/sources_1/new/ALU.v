`include "opcodes.v"

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
            `OP_ADD: begin
                {Cout, C} = {A + B + Cin};
                branch_cond = 0;
            end
            `OP_SUB: begin
                {Cout, C} = {A - (B + Cin)};
                branch_cond = 0;
            end
            `OP_AND: begin
                Cout = 0;
                C = A & B;
                branch_cond = 0;
            end
            `OP_OR: begin
                Cout = 0;
                C = A | B;
                branch_cond = 0;
            end
            `OP_NOT: begin
                Cout = 0;
                C = ~A;
                branch_cond = 0;
            end
            `OP_TCP: begin
                Cout = 0;
                C = ~A + 1;
                branch_cond = 0;
            end
            `OP_SHL: begin
                Cout = 0;
                C = A << 1;
                branch_cond = 0;
            end
            `OP_SHR: begin
                Cout = 0;
                C = A >> 1;
                C[15] = C[14];
                branch_cond = 0;
            end
            `OP_LHI: begin
                Cout = 0;
                C = C << 8;
                branch_cond = 0;
            end
            `OP_BNE: begin
                Cout = 0;
                C = 0;
                branch_cond = A != B;
            end
            `OP_BEQ: begin
                Cout = 0;
                C = 0;
                branch_cond = A == B;
            end
            `OP_BGZ: begin
                Cout = 0;
                C = 0;
                branch_cond = $signed(A) > 0;
            end
            `OP_BLZ: begin
                Cout = 0;
                C = 0;
                branch_cond = $signed(A) < 0;
            end
            `OP_BRAADD: begin
                Cout = 0;
                C = A + B;
                branch_cond = 0;
            end
            `OP_ID: {Cout, C, branch_cond} = {0, A, 0}; // just for filling
            `OP_ZERO: {Cout, C, branch_cond} = {0, 0, 0}; // just for filling
        endcase
     end
endmodule
