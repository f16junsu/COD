`include "opcodes.v"
`include "constants.v"

module BTB(
    input clk,
    input reset_n,
    // input signals
    input BTB_forward_PC,
    input BTBupdate,
    // input address for update and data(target) for update
    input [`WORD_SIZE-1:0] update_addr,
    input [`WORD_SIZE-1:0] update_data,
    // actual PC for internal forwarding
    input [`WORD_SIZE-1:0] actual_next_PC,
    // input address to read table
    input [`WORD_SIZE-1:0] read_addr,

    output [`WORD_SIZE-1:0] nextPC
    );
    reg [`WORD_SIZE:0] BTB_table [0:255]; // {valid_bit, word}
    integer c;

    assign nextPC = BTB_forward_PC ? actual_next_PC : // internal forwarding next PC
                    BTB_table[read_addr][`WORD_SIZE] ? BTB_table[read_addr][`WORD_SIZE-1:0]:
                    read_addr + 1;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (c=0; c < 256; c = c + 1) begin
                BTB_table[c] <= 0;
            end
        end
        else begin
            if (BTBupdate) begin
                BTB_table[update_addr] <= {1'b1, update_data};
            end
        end
    end
endmodule
