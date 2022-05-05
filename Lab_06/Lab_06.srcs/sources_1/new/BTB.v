`include "opcodes.v"
`include "constants.v"

module BTB(
    input clk,
    input reset_n,
    // input signals
    input BTBupdate_ID,
    input BTBupdate_MEM,
    // input address for update and data(target) for update
    input [`WORD_SIZE-1:0] update_addr,
    input [`WORD_SIZE-1:0] update_data,
    // input address to read table
    input [`WORD_SIZE-1:0] read_addr,

    output BTBmiss,
    output [`WORD_SIZE-1:0] nextPC
    );
    reg [`WORD_SIZE:0] BTB_table [0:`MEMORY_SIZE-1]; // {valid_bit, word}
    integer c;

    assign BTBmiss = (read_addr != `IDLE) & BTB_table[read_addr][`WORD_SIZE];
    assign nextPC = (read_addr == `IDLE) ? `IDLE:
                    BTB_table[read_addr][`WORD_SIZE] ? BTB_table[read_addr][`WORD_SIZE-1:0] : `IDLE;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            for (c=0; c < `MEMORY_SIZE; c = c + 1) begin
                BTB_table[c] <= {0, `IDLE};
            end
        end
        else begin
            if (BTBupdate_ID | BTBupdate_MEM) begin
                BTB_table[update_addr] <= update_data;
            end
        end

    end
endmodule
