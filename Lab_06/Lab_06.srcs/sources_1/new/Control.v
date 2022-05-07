`include "opcodes.v"
`include "constants.v"

module Control(
    input [`WORD_SIZE-1:0] instruction,

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
    output reg isBranchorJmp,

    // Blue EX Block Register
    output reg outputenable,
    output reg [1:0] RegDest,
    output reg [3:0] ALUop,
    output reg [1:0] ALUSource
    );

    always @(*) begin
        case (instruction[15:12])
            `OPCODE_IDLE: begin
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
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_RTYPE: begin
                case (instruction[5:0])
                    `FUNC_ADD, `FUNC_SUB, `FUNC_AND, `FUNC_ORR: begin
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
                        isBranchorJmp = 0;
                        outputenable = 0;
                        RegDest = 2'b01;
                        ALUop = instruction[3:0];
                        ALUSource = 2'b00;
                    end
                    `FUNC_NOT, `FUNC_TCP, `FUNC_SHL, `FUNC_SHR: begin
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
                        isBranchorJmp = 0;
                        outputenable = 0;
                        RegDest = 2'b01;
                        ALUop = instruction[3:0];
                        ALUSource = 2'b00;
                    end
                    `FUNC_JPR: begin
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
                        isBranchorJmp = 1;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_JRL: begin
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
                        isBranchorJmp = 1;
                        outputenable = 0;
                        RegDest = 2'b10;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_HLT: begin
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
                        isBranchorJmp = 0;
                        outputenable = 0;
                        RegDest = 2'b00;
                        ALUop = `OP_ID;
                        ALUSource = 2'b00;
                    end
                    `FUNC_WWD: begin
                        isHLT = 0;
                        use_rs = 1;
                        use_rt = 0;
                        valid_inst = 1;
                        MemtoReg = 0;
                        RegWrite = 0;
                        PCSource = 2'b00;
                        isBranchorJmp = 0;
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
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_ORI: begin
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
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_OR;
                ALUSource = 2'b10;
            end
            `OPCODE_LHI: begin
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
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_LHI;
                ALUSource = 2'b00;
            end
            `OPCODE_LWD: begin
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
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_SWD: begin
                isHLT = 0;
                use_rs = 1;
                use_rt = 1;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 1;
                PCSource = 2'b00;
                isBranchorJmp = 0;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ADD;
                ALUSource = 2'b01;
            end
            `OPCODE_BNE: begin
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
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BNE;
                ALUSource = 2'b00;
            end
            `OPCODE_BEQ: begin
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
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BEQ;
                ALUSource = 2'b00;
            end
            `OPCODE_BGZ: begin
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BGZ;
                ALUSource = 2'b00;
            end
            `OPCODE_BLZ: begin
                isHLT = 0;
                use_rs = 1;
                use_rt = 0;
                valid_inst = 1;
                MemtoReg = 0;
                RegWrite = 0;
                isLink = 0;
                MemRead = 0;
                MemWrite = 0;
                PCSource = 2'b00;
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_BLZ;
                ALUSource = 2'b00;
            end
            `OPCODE_JMP: begin
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
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b00;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
            `OPCODE_JAL: begin
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
                isBranchorJmp = 1;
                outputenable = 0;
                RegDest = 2'b10;
                ALUop = `OP_ID;
                ALUSource = 2'b00;
            end
        endcase
    end
endmodule
