`include "opcodes.v"
`include "constants.v"

module Control(
    input BTBmiss_gen,
    input should_stall,
    input [`WORD_SIZE-1:0] instruction,

    output reg isStall,
    output reg isHLT,
    output reg use_rs,
    output reg use_rt,

    // Blue WB Block Register
    output reg valid_inst,
    output reg MemtoReg,
    output reg RegWrite,
    output reg isLink,

    // Blue MEM Block Register
    output reg MemRead,
    output reg MemWrite,
    output reg [1:0] PCSource,
    output reg BTBmiss,

    // Blue EX Block Register
    output reg outputenable,
    output reg [1:0] RegDest,
    output reg [3:0] ALUop,
    output reg [1:0] ALUSource
    );

    always @(*) begin
        if (should_stall) begin // stall when RAW hazard
                    isStall = 1;
                    isHLT = 0;
                    use_rs = 0;
                    use_rt = 0;
                    valid_inst = 0;
                    MemtoReg = 0;
                    RegWrite = 0;
                    isLink = 0;
                    MemRead = 0;
                    MemWrite = 0;
                    PCSource = 2'b00;
                    BTBmiss = 0;
                    outputenable = 0;
                    RegDest = 2'b00;
                    ALUop = `OP_ID;
                    ALUSource = 2'b00;
                end
        else begin
        case (instruction[15:12])
            `OPCODE_IDLE: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 0;
                use_rt = 0;
                valid_inst = 0;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_RTYPE: begin
                case (instruction[5:0])
                    `FUNC_ADD, `FUNC_SUB, `FUNC_AND, `FUNC_ORR: begin
                        isStall = 0;
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 1;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 1;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        PCSource = 2'b00;
                        BTBmiss = 0;
                        outputenable = 0;
                        RegDest = 2'b01;
                        ALUop = instruction[3:0];
                        ALUSource = 2'b00;
                    end
                    `FUNC_NOT, `FUNC_TCP, `FUNC_SHL, `FUNC_SHR: begin
                        isStall = 0;
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 1;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        PCSource = 2'b00;
                        BTBmiss = 0;
                        outputenable = 0;
                        RegDest = 2'b01;
                        ALUop = instruction[3:0];
                        ALUSource = 2'b00;
                    end
                    `FUNC_JPR: begin
                        isStall = 0;
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        PCSource = 2'b10;
                        BTBmiss = BTBmiss_gen;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_JRL: begin
                        isStall = 0;
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 1;
                        isLink = 1;
                        MemRead = 0;
                        MemWrite = 0;
                        PCSource = 2'b10;
                        BTBmiss = BTBmiss_gen;
                        outputenable = 0;
                        RegDest = 2'b10;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_HLT: begin
                        isStall = 1;
                        isHLT = 1;
                        use_rs = 0;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        PCSource = 2'b00;
                        BTBmiss = 0;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_WWD: begin
                        isStall = 0;
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 0;
                        PCSource = 2'b00;
                        BTBmiss = 0;
                        isLink = 0;
                        MemRead = 0;
                        MemWrite = 0;
                        outputenable = 1;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                endcase
            end
            `OPCODE_ADI: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_ORI: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_OR;
                ALUSource = 2'b10;
            end
            `OPCODE_LHI: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 0;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b01;
                ALUop = `OP_LHI;
                ALUSource = 2'b00;
            end
            `OPCODE_LWD: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 1;
                RegWrite = 1;
                isLink = 0;
                MemRead = 1;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_SWD: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 1;
                PCSource = 2'b00;
                BTBmiss = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_BNE: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 1;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BNE;
                ALUSource = 2'b00;
            end
            `OPCODE_BEQ: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 1;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BEQ;
                ALUSource = 2'b00;
            end
            `OPCODE_BGZ: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 1;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BGZ;
                ALUSource = 2'b00;
            end
            `OPCODE_BLZ: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 1;
                use_rt = 1;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BLZ;
                ALUSource = 2'b00;
            end
            `OPCODE_JMP: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 0;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b01;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_JAL: begin
                isStall = 0;
                isHLT = 0;
                use_rs = 0;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 1;
                isLink = 1;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b01;
                BTBmiss = BTBmiss_gen;
                outputenable = 0;
                RegDest = 2'b10;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
        endcase
        end
    end
endmodule
