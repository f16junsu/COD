`define WORD_SIZE 16
/*************************************************
* DMA module (DMA.v)
* input: clock (CLK), bus request (BR) signal,
*        data from the device (edata), and DMA command (cmd)
* output: bus grant (BG) signal
*         READ signal
*         memory address (addr) to be written by the device,
*         offset device offset (0 - 2)
*         data that will be written to the memory
*         interrupt to notify DMA is end
* You should NOT change the name of the I/O ports and the module name
* You can (or may have to) change the type and length of I/O ports
* (e.g., wire -> reg) if you want
* Do not add more ports!
*************************************************/

module DMA (
    input CLK, BG,
    input [4 * `WORD_SIZE - 1 : 0] edata,
    input cmd,
    output reg BR, READ,
    output reg [`WORD_SIZE - 1 : 0] addr,
    output [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt);
    /* Implement your own logic */
    reg [3:0] memory_counter;
    reg in_process;

    initial begin
        BR <= 1'b0;
        READ <= 1'b0;
        offset <= 2'b11;
        memory_counter <= 4'b0;
        interrupt <= 1'b0;
        addr <= 16'h01f4;
        in_process <= 1'b0;
    end

    // receive command
    always @(posedge cmd) begin
        if (cmd) begin
            BR <= 1'b1;
        end
    end

    // for memory write. 4 cycles for 4 word bandwidth
    // deassert BR whenever 4 word are written
    assign data = edata;
    always @(posedge CLK) begin
        if (BG) begin
            case (memory_counter)
                4'b0000: ;
                4'b0001: memory_counter <= memory_counter + 1;
                4'b0010: memory_counter <= memory_counter + 1;
                4'b0011: memory_counter <= memory_counter + 1;
                4'b0100: begin
                    BR <= 1'b0;
                    READ <= 1'b0;
                end
                4'b0101: memory_counter <= memory_counter + 1;
                4'b0110: memory_counter <= memory_counter + 1;
                4'b0111: memory_counter <= memory_counter + 1;
                4'b1000: begin
                    BR <= 1'b0;
                    READ <= 1'b0;
                end
                4'b1001: memory_counter <= memory_counter + 1;
                4'b1010: memory_counter <= memory_counter + 1;
                4'b1011: memory_counter <= memory_counter + 1;
                4'b1100: begin
                    in_process <= 1'b0;
                    BR <= 1'b0;
                    READ <= 1'b0;
                end
            endcase
        end
    end
    // to execute dma work
    always @(posedge BG) begin
        case (memory_counter)
            4'b0000: begin
                in_process <= 1'b1;
                offset <= 2'b00;
                READ <= 1'b1;
                memory_counter <= memory_counter + 1;
            end
            4'b0100: begin
                offset <= 2'b01;
                READ <= 1'b1;
                addr <= addr + 4;
                memory_counter <= memory_counter + 1;
            end
            4'b1000: begin
                offset <= 2'b10;
                READ <= 1'b1;
                addr <= addr + 4;
                memory_counter <= memory_counter + 1;
            end
            default: ;
        endcase
    end
    // to rerequest bus
    always @(posedge CLK) begin
        if (in_process && !BG) begin
            case (memory_counter)
                4'b0100: BR <= 1'b1;
                4'b1000: BR <= 1'b1;
                default: ;
            endcase
        end
    end


    // end
    always @(negedge in_process) begin
        interrupt <= 1'b1;
        BR <= 1'b0;
        READ <= 1'b0;
        offset <= 2'b11;
        memory_counter <= 4'b0;
        addr <= 16'h01f4;
    end
    always @(posedge CLK) begin
        if (interrupt) interrupt <= 1'b0;
    end
endmodule
