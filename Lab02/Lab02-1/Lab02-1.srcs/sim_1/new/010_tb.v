`timescale 100ps / 100ps

`define CLOCK_PERIOD 10
`define PATTERN_LEN 128

module detector_tb;

/* input to the detector */
reg CLK;
reg reset_n;
reg in;

/* output from the detector */
wire out;

/* internal counter for test */
integer i;
integer Passed;

// Connect the detector to detector_tb
// Please follow name specified here.
detector UUT (
    .clk(CLK),
    .reset_n(reset_n),
    .in(in),
    .out(out));

/* Clock generator */
always #(`CLOCK_PERIOD/2) CLK = ~CLK;

reg [0 : `PATTERN_LEN - 1] pattern;
reg [0 : `PATTERN_LEN - 1] ans;

initial begin 
    CLK = 0;
    in = 0;
    reset_n = 1;

    /* if you change the input stream, change the below */
    pattern = `PATTERN_LEN'b00001101111101000010110010110011110000101101010111011011100000101111101011011011101010100001010001001100001110010000110011010010;
    ans     = `PATTERN_LEN'b00000000000000100001000001000000000000010000101000000000000000010000000100000000000101010000101000100000000000001000000000001001;
    
    /* Checking # of passes */
    Passed = 0;

    // reset
    #(`CLOCK_PERIOD/2) reset_n = 0; 
    #(`CLOCK_PERIOD + `CLOCK_PERIOD/2) reset_n = 1; 

    #(`CLOCK_PERIOD);

    for (i = 0 ; i < `PATTERN_LEN; i = i + 1) begin
        in = pattern[i];
        #(`CLOCK_PERIOD);

        if (out == ans[i]) Passed = Passed + 1;
    end


	$display("Passed = %0d, Failed = %0d", Passed, `PATTERN_LEN - Passed);	
    $finish;
end

endmodule // detector_tb



