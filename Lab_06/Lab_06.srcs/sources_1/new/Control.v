`include "opcodes.v"
`include "constants.v"

module Control(
    input BTBmiss,
    input should_stall,
    input [`WORD_SIZE-1:0] instruction,

    output reg PCLatch_ID,
    output reg isStall,
    output reg isHLT,

    // Blue WB Block Register
    output reg MemtoReg,
    output reg RegWrite,
    output reg isLink,

    // Blue MEM Block Register
    output reg MemRead,
    output reg MemWrite,
    output reg isJR,
    output reg isBranch,
    output reg PCLatch_MEM,

    // Blue EX Block Register
    output reg outputenable,
    output reg [1:0] RegDest,
    output reg [3:0] ALUop,
    output reg [1:0] ALUSource
    );

    always @(*) begin
        if (should_stall) begin // stall when RAW hazard
                    PCLatch_ID = BTBmiss ? 1 : 0;
                    isStall = 1;
                    isHLT = 0;
                    MemtoReg = 0;
                    RegWrite = 0;
                    isLink = 0;
                    MemRead = 0;
                    MemWrite = 0;
                    isJR = 0;
                    isBranch 0;
                    PCLatch_MEM = 0;
                    outputenable = 0;
                    RegDest = 2'b00;
                    ALUop = `OP_ID;
                    ALUSource = 2'b00;
                end
        else begin
        case (instruction[15:12])
            `OPCODE_IDLE: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_RTYPE: begin
                case (instruction[5:0])
                    `FUNC_ADD, `FUNC_SUB, `FUNC_AND, `FUNC_OR, `FUNC_NOT, `FUNC_TCP, `FUNC_SHL, `FUNC_SHR: begin
                        PCLatch_ID = BTBmiss ? 1 : 0;
                        isStall = 0;
                        isHLT = 0;
                        MemtoReg = 0;
                        RegWrite = 1;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        isJR = 0;
                        isBranch 0;
                        PCLatch_MEM = 0;
                        outputenable = 0;
                        RegDest = 2'b01;
                        ALUop = instruction[3:0];
                        ALUSource = 2'b00;
                    end
                    `FUNC_JPR: begin
                        PCLatch_ID = 0;
                        isStall = 0;
                        isHLT = 0;
                        MemtoReg = 0;
                        RegWrite = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        isJR = 1;
                        isBranch = 0;
                        PCLatch_MEM = BTBmiss ? 1 : 0;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_JRL: begin
                        PCLatch_ID = 0;
                        isStall = 0;
                        isHLT = 0;
                        MemtoReg = 0;
                        RegWrite = 1;
                        isLink = 1;
                        MemRead = 0;
                        MemWrite = 0;
                        isJR = 1;
                        isBranch = 0;
                        PCLatch_MEM = BTBmiss ? 1 : 0;
                        outputenable = 0;
                        RegDest = 2'b10;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_HLT: begin
                        PCLatch_ID = 0;
                        isStall = 1;
                        isHLT = 1;
                        MemtoReg = 0;
                        RegWrite = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        isJR = 0;
                        isBranch = 0;
                        PCLatch_MEM = 0;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_WWD: begin
                        PCLatch_ID = BTBmiss ? 1 : 0;
                        isStall = 0;
                        isHLT = 0;
                        MemtoReg = 0;
                        RegWrite = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        isJR = 0;
                        isBranch = 0;
                        PCLatch_MEM = 0;
                        outputenable = 1;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                endcase
            end
            `OPCODE_ADI: begin
                PCLatch_ID = BTBmiss ? 1 : 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_ORI: begin
                PCLatch_ID = BTBmiss ? 1 : 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_OR;
                ALUSource = 2'b10;
            end
            `OPCODE_LHI: begin
                PCLatch_ID = BTBmiss ? 1 : 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_LHI;
                ALUSource = 2'b00;
            end
            `OPCODE_LWD: begin
                PCLatch_ID = BTBmiss ? 1 : 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 1;
                RegWrite = 1;
                isLink = 0;
                MemRead = 1;
                MemWrite = 0;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_SWD: begin
                PCLatch_ID = BTBmiss ? 1 : 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 1;
                isJR = 0;
                isBranch 0;
                PCLatch_MEM = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_BNE: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 1;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BNE;
                ALUSource = 2'b00;
            end
            `OPCODE_BEQ: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 1;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BEQ;
                ALUSource = 2'b00;
            end
            `OPCODE_BGZ: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 1;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BGZ;
                ALUSource = 2'b00;
            end
            `OPCODE_BLZ: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 1;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BLZ;
                ALUSource = 2'b00;
            end
            `OPCODE_JMP: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 0;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_JAL: begin
                PCLatch_ID = 0;
                isStall = 0;
                isHLT = 0;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 1;
                MemRead = 0;
                MemWrite = 0;
                isJR = 0;
                isBranch = 0;
                PCLatch_MEM = BTBmiss ? 1 : 0;
                outputenable = 0;
                RegDest = 2'b10;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
        endcase
        end
    end
endmodule
