`timescale 100ps / 100ps

module detector(
    input in,
    input clk,
    input reset_n,

    output out
    );
    reg [1:0] state; // Using the former two numbers as states
    reg out;

   
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin // reset
            out <= 1'b0;
            state <= 2'b00;
        end
        else begin
                case (state) // with state and input to update state and output
                    2'b00: {out, state} <= in ? 3'b001 : 3'b000; 
                    2'b01: {out, state} <= in ? 3'b011 : 3'b110;
                    2'b10: {out, state} <= in ? 3'b001 : 3'b000;
                    2'b11: {out, state} <= in ? 3'b011 : 3'b010;
                    default: {out, state} <= 3'b000;
                endcase
         end
    end
    
endmodule