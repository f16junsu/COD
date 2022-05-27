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
    output reg [4 * `WORD_SIZE - 1 : 0] data,
    output reg [1:0] offset,
    output reg interrupt);
    /* Implement your own logic */
    reg [3:0] memory_counter;
    reg [4*`WORD_SIZE-1:0] data_buffer [2:0];

    initial begin
        BR <= 1'b0;
        READ <= 1'b0;
        offset <= 2'b11;
        memory_counter <= 4'b0;
        interrupt <= 1'b0;
        addr <= 16'h01f4;
    end

    // receive command
    always @(posedge cmd) begin
        if (cmd) begin
            BR <= 1'b1;
        end
    end

    // start reading data from external_device. 1 cycle per each line
    always @(CLK) begin
        if (BG) begin
            case (offset)
                2'b11: if (CLK) offset <= 2'b00;
                2'b00: begin
                    if (CLK) offset <= 2'b01;
                    else data_buffer[offset] <= edata;
                end
                2'b01: begin
                    if (CLK) offset <= 2'b10;
                    else data_buffer[offset] <= edata;
                end
                2'b10: if (!CLK) data_buffer[offset] <= edata;
            endcase
        end
    end

    // for memory write. 4 cycles for 4 word bandwidth
    always @(posedge CLK) begin
        if (offset == 2'b10) begin
            case (memory_counter)
                4'b0000: begin
                    READ <= 1;
                    data <= data_buffer[0];
                    memory_counter <= memory_counter + 1;
                end
                4'b0001: memory_counter <= memory_counter + 1;
                4'b0010: memory_counter <= memory_counter + 1;
                4'b0011: memory_counter <= memory_counter + 1;
                4'b0100: begin
                    data <= data_buffer[1];
                    addr <= addr + 4;
                    memory_counter <= memory_counter + 1;
                end
                4'b0101: memory_counter <= memory_counter + 1;
                4'b0110: memory_counter <= memory_counter + 1;
                4'b0111: memory_counter <= memory_counter + 1;
                4'b1000: begin
                    data <= data_buffer[2];
                    addr <= addr + 4;
                    memory_counter <= memory_counter + 1;
                end
                4'b1001: memory_counter <= memory_counter + 1;
                4'b1010: memory_counter <= memory_counter + 1;
                4'b1011: memory_counter <= memory_counter + 1;
                4'b1100: begin
                    READ <= 0;
                    BR <= 1'b0;
                end
            endcase
        end
    end

    always @(negedge BG) begin
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
