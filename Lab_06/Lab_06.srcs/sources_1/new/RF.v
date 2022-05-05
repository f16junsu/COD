module RF(
    input [1:0] addr1,
    input [1:0] addr2,
    input [1:0] addr3,
    input [15:0] data3,

    input write,
    input clk,
    input reset_n,

    output [15:0] data1,
    output [15:0] data2
    );

    reg [15:0] internal_register[0:3]; // reg [15:0] array length with 4 to save the data
    reg [15:0] data1;
    reg [15:0] data2;

    always @(*) begin // asynchronous read functionality
        data1 = internal_register[addr1];
        data2 = internal_register[addr2];
    end

    always @(negedge clk or negedge reset_n) begin
        if (!reset_n) begin // reset
            internal_register[2'b00] <= 16'b0;
            internal_register[2'b01] <= 16'b0;
            internal_register[2'b10] <= 16'b0;
            internal_register[2'b11] <= 16'b0;
        end
        else begin
            if (write) begin // if write is high
                internal_register[addr3] <= data3;
            end
        end
    end
endmodule
