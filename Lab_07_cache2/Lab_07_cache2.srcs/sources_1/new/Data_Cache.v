`include "opcodes.v"
`include "constants.v"

module Data_Cache(
    input clk,
    input reset_n,

    // path between Datapath
    input readC,
    input writeC,
    input [`WORD_SIZE-1:0] address,
    output reg ready,
    output reg w_done,
    inout [`WORD_SIZE-1:0] data,

    // path between memory
    inout [`LINE_SIZE-1:0] line_mem,
    output reg readM,
    output reg writeM,
    output [`WORD_SIZE-1:0] address_to_mem
    );
    reg [`TAG_SIZE + `LINE_SIZE + 1:0] cache_table [0:3];
    reg [1:0] status;
    // reg [`WORD_SIZE-1:0] output_data;
    reg [`WORD_SIZE-1:0] hit_counter;
    reg [`WORD_SIZE-1:0] miss_counter;
    wire [1:0] idx;
    wire [1:0] bo;
    wire [`WORD_SIZE-1:0] selected_word;

    assign idx = address[3:2];
    assign bo = address[1:0];
    assign data = ready? selected_word : 16'bz;
    assign selected_word = (bo == 2'b00) ? cache_table[idx][`WORD_SIZE-1:0]:
                           (bo == 2'b01) ? cache_table[idx][2*`WORD_SIZE-1:`WORD_SIZE]:
                           (bo == 2'b10) ? cache_table[idx][3*`WORD_SIZE-1:2*`WORD_SIZE]:
                           cache_table[idx][4*`WORD_SIZE-1:3*`WORD_SIZE];
    assign line_mem = writeM? {3*`WORD_SIZE'b0, data} : 78'bz;
    assign address_to_mem = address;

    always @(negedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ready <= 1'b0;
            status <= 2'b00;
            hit_counter <= 16'b0;
            miss_counter <= 16'b0;
            readM <= 0;
            writeM <= 0;
            w_done <= 0;
            cache_table[0] <= 78'b0;
            cache_table[1] <= 78'b0;
            cache_table[2] <= 78'b0;
            cache_table[3] <= 78'b0;
        end
        else begin
            if (readC) begin
                case (status)
                    2'b00: begin // initial state
                        if (cache_table[idx][`TAG_SIZE + `LINE_SIZE]) begin // if valid
                            if (cache_table[idx][`TAG_SIZE-1 + `LINE_SIZE:`LINE_SIZE] == address[`WORD_SIZE-1:4]) begin // hit
                                hit_counter <= hit_counter + 1;
                                ready <= 1;
                            end
                            else begin // miss
                                miss_counter <= miss_counter + 1;
                                status <= 2'b01;
                                readM <= 1;
                            end
                        end
                        else begin // if invalid(miss)
                            miss_counter <= miss_counter + 1;
                            status <= 2'b01;
                            readM <= 1;
                        end
                    end
                    2'b01: status <= 2'b10;
                    2'b10: status <= 2'b11;
                    2'b11: begin
                        readM <= 0;
                        cache_table[idx] <= {1'b1, address[`WORD_SIZE-1:4], line_mem};
                        ready <= 1;
                        status <= 2'b00;
                    end
                endcase
            end
            else if (writeC) begin
                case (status)
                    2'b00: begin // initial state
                        if (cache_table[idx][`TAG_SIZE + `LINE_SIZE]) begin // if valid
                            if (cache_table[idx][`TAG_SIZE-1 + `LINE_SIZE:`LINE_SIZE] == address[`WORD_SIZE-1:4]) begin // hit
                                hit_counter <= hit_counter + 1;
                                case (bo)
                                    2'b00: cache_table[idx][`WORD_SIZE-1:0] <= data;
                                    2'b01: cache_table[idx][2*`WORD_SIZE-1:`WORD_SIZE] <= data;
                                    2'b10: cache_table[idx][3*`WORD_SIZE-1:2*`WORD_SIZE] <= data;
                                    2'b11: cache_table[idx][4*`WORD_SIZE-1:3*`WORD_SIZE] <= data;
                                endcase
                                status <= 2'b01;
                                writeM <= 1;
                            end
                            else begin // miss
                                miss_counter <= miss_counter + 1;
                                status <= 2'b01;
                                writeM <= 1;
                            end
                        end
                        else begin // if invalid(miss)
                            miss_counter <= miss_counter + 1;
                            status <= 2'b01;
                            writeM <= 1;
                        end
                    end
                    2'b01: status <= 2'b10;
                    2'b10: status <= 2'b11;
                    2'b11: begin
                        writeM <= 0;
                        status <= 2'b00;
                        w_done <= 1;
                    end
                endcase
            end
        end
    end
    always @(posedge clk) begin
        ready <= 0;
        w_done <= 0;
    end
endmodule
