`timescale 100ps / 100ps

`define WORD_SIZE 16
`define CLOCK_PERIOD 10
`define NUM_ADDR 3
`define NUM_REG 4

module RF_tb;

/* input to the RF */
reg reset_n;
reg CLK;
reg write;
reg [1 : 0] addr [0:`NUM_ADDR - 1];
reg [`WORD_SIZE - 1 : 0] w_data ;

/* output from RF */
wire [`WORD_SIZE - 1 : 0] r_data [0:1];

/* internal counter for test */
integer i;
integer Passed;
integer Failed;
integer n_write;
integer n_read;
integer n_sync;

reg [`WORD_SIZE * `NUM_REG - 1 : 0 ] regs;
wire [`WORD_SIZE - 1 : 0 ] reg_wires [`NUM_REG - 1 : 0];

assign reg_wires[0] = regs[15:0];
assign reg_wires[1] = regs[31:16];
assign reg_wires[2] = regs[47:32];
assign reg_wires[3] = regs[63:48];

// Connect the RF to RF_tb
// Please follow name specified here.
RF rf (
    .write(write),
    .clk(CLK),
    .reset_n(reset_n),
    .addr1(addr[0]),
    .addr2(addr[1]),
    .addr3(addr[2]),
    .data1(r_data[0]),
    .data2(r_data[1]),
    .data3(w_data));

/* Clock generator */
always #(`CLOCK_PERIOD/2) CLK = ~CLK;

task read_all_regs;
    begin
        addr[0] = 0;
        addr[1] = 1;
        #(`CLOCK_PERIOD);
        regs[15 : 0] = r_data[0];
        regs[31 : 16] = r_data[1]; 
        
        addr[0] = 2;
        addr[1] = 3;
        #(`CLOCK_PERIOD);
        regs[47 : 32] = r_data[0];
        regs[63 : 48] = r_data[1]; 
        #(`CLOCK_PERIOD);
    end
endtask

task Test;
	input [16 * 8 : 0] Testname;
    input [`WORD_SIZE * `NUM_REG - 1 : 0] ans;

    begin 
        read_all_regs;

        $display("TEST %s :", Testname);
        if (ans == regs) begin
            $display("PASSED");
            Passed = Passed + 1;
        end
        else begin
            $display("FAILED");
            Failed = Failed + 1;
        end
    end
endtask

task Reset_test;
    begin 
        reset_n = 1;
        #(`CLOCK_PERIOD);
        reset_n = 0;
        #(`CLOCK_PERIOD);
        reset_n = 1;

        Test("reset", 64'h0);
    end
endtask

task check_partial;
    input integer A;
    input integer B;
    input integer C;
    input [`WORD_SIZE * 3 - 1: 0] ans;
    input [`WORD_SIZE - 1 : 0] data;
    reg success;

    begin
        success = 0;

        if ( (ans[`WORD_SIZE * (0 + 1) - 1 : `WORD_SIZE * (0)] == r_data[0] || 
            (A == C) && r_data[0] === data)
            && 
            (ans[`WORD_SIZE * (1 + 1) - 1 : `WORD_SIZE * (1)] == r_data[1] )  ||
            (B == C) && r_data[1] === data)
        begin

            read_all_regs;

            if ( ans[`WORD_SIZE * 3 -1 : `WORD_SIZE * 2] == reg_wires[C] )
            begin
                success = 1;
            end
        end

        if (success) begin
            $display("PASSED");
            Passed = Passed + 1;
        end
        else  begin

            $display("FAILED");

            Failed = Failed + 1;
        end
    end
endtask

task Read_test;
    input integer A;
    input integer B;
    input integer C;
    
    input [`WORD_SIZE - 1 : 0] data;
    input [`WORD_SIZE * 3 - 1 : 0] ans;

    begin
        n_read = n_read + 1;
        write = 0;
        reset_n = 1;

        addr[0] = A;
        addr[1] = B;
        addr[2] = C;
        w_data = data;
        
        #(`CLOCK_PERIOD);

        $display("TEST read %d :", n_read);
        check_partial(A,B,C, ans, 16'hx);
    end
endtask

task Write_test;
    input integer A;
    input integer B;
    input integer C;

    input [`WORD_SIZE - 1 : 0] data;
    input [`WORD_SIZE * 3 - 1: 0] ans;

    begin
        n_write = n_write + 1;
        write = 1;
        reset_n = 1;

        addr[0] = A;
        addr[1] = B;
        addr[2] = C;
        w_data = data;
        
        #(`CLOCK_PERIOD);
        write = 0;

        $display("TEST write %d :", n_write);
        check_partial(A,B,C, ans, data);
    end
endtask


task Sync_test;
    input integer A;
    input integer B;
    input integer C;
    input [`WORD_SIZE - 1 : 0] data;
    input [`WORD_SIZE * `NUM_REG - 1 : 0] ans;

    begin
        n_sync = n_sync + 1;
        write = 1;
        reset_n = 1;

        addr[0] = A;
        addr[1] = B;
        addr[2] = C;
        w_data = data;
        
        #(`CLOCK_PERIOD / 2);

        write = 0;
        
        #(`CLOCK_PERIOD / 2);

        $display("TEST sync %d:", n_sync);
        check_partial(A,B,C, ans, 16'hx);
    end
endtask

initial begin 
    CLK = 0;
    reset_n = 1;
    write = 0;

    for(i = 0; i < `NUM_ADDR; i = i + 1) begin
        addr[i] = 0;
    end
    w_data = `WORD_SIZE'hzzzz;

    Passed = 0;
    Failed = 0; 
    n_write = 0;
    n_read = 0;
    n_sync = 0;
    
    Reset_test;

    Write_test(2'b11,	2'b10,	2'b11,	`WORD_SIZE'h52df,	48'h52df00000000);
    Write_test(2'b10,	2'b1,	2'b0,	`WORD_SIZE'h5cb1,	48'h5cb100000000);
    Write_test(2'b10,	2'b10,	2'b0,	`WORD_SIZE'hc6d6,	48'hc6d600000000);
    Write_test(2'b0,	2'b1,	2'b1,	`WORD_SIZE'h7953,	48'h79530000c6d6);
    Write_test(2'b0,	2'b1,	2'b0,	`WORD_SIZE'hbca6,	48'hbca67953c6d6);
    Write_test(2'b11,	2'b0,	2'b1,	`WORD_SIZE'h7251,	48'h7251bca652df);
    Write_test(2'b0,	2'b11,	2'b0,	`WORD_SIZE'h1f2c,	48'h1f2c52dfbca6);
    Write_test(2'b11,	2'b10,	2'b10,	`WORD_SIZE'h9aeb,	48'h9aeb000052df);
    Write_test(2'b11,	2'b10,	2'b0,	`WORD_SIZE'hc505,	48'hc5059aeb52df);
    Write_test(2'b11,	2'b1,	2'b11,	`WORD_SIZE'hff78,	48'hff78725152df);
    Write_test(2'b10,	2'b0,	2'b1,	`WORD_SIZE'h2795,	48'h2795c5059aeb);
    Write_test(2'b10,	2'b10,	2'b11,	`WORD_SIZE'h15ca,	48'h15ca9aeb9aeb);
    Write_test(2'b11,	2'b1,	2'b11,	`WORD_SIZE'h838,	48'h0838279515ca);
    Write_test(2'b11,	2'b1,	2'b10,	`WORD_SIZE'h93b5,	48'h93b527950838);
    Write_test(2'b1,	2'b1,	2'b11,	`WORD_SIZE'h51ed,	48'h51ed27952795);
    Write_test(2'b1,	2'b1,	2'b1,	`WORD_SIZE'h8c19,	48'h8c1927952795);
    Read_test(2'b0,	2'b0,	2'b1,	`WORD_SIZE'ha0e4,	48'h8c19c505c505);
    Read_test(2'b1,	2'b10,	2'b11,	`WORD_SIZE'hdf70,	48'h51ed93b58c19);
    Read_test(2'b1,	2'b0,	2'b10,	`WORD_SIZE'h7c45,	48'h93b5c5058c19);
    Read_test(2'b0,	2'b10,	2'b0,	`WORD_SIZE'hf86d,	48'hc50593b5c505);
    Read_test(2'b0,	2'b1,	2'b1,	`WORD_SIZE'h17fe,	48'h8c198c19c505);
    Read_test(2'b1,	2'b1,	2'b0,	`WORD_SIZE'hc9ef,	48'hc5058c198c19);
    Read_test(2'b1,	2'b10,	2'b1,	`WORD_SIZE'h9f73,	48'h8c1993b58c19);
    Read_test(2'b11,	2'b0,	2'b1,	`WORD_SIZE'h57fa,	48'h8c19c50551ed);
    Read_test(2'b1,	2'b11,	2'b10,	`WORD_SIZE'h96bf,	48'h93b551ed8c19);
    Read_test(2'b11,	2'b1,	2'b11,	`WORD_SIZE'he8be,	48'h51ed8c1951ed);
    Read_test(2'b0,	2'b0,	2'b10,	`WORD_SIZE'hdf6,	48'h93b5c505c505);
    Read_test(2'b11,	2'b10,	2'b0,	`WORD_SIZE'h5387,	48'hc50593b551ed);
    Read_test(2'b10,	2'b10,	2'b0,	`WORD_SIZE'hd473,	48'hc50593b593b5);
    Read_test(2'b0,	2'b0,	2'b10,	`WORD_SIZE'hdaca,	48'h93b5c505c505);
    Read_test(2'b1,	2'b0,	2'b10,	`WORD_SIZE'h88d6,	48'h93b5c5058c19);
    Read_test(2'b0,	2'b0,	2'b11,	`WORD_SIZE'h2be4,	48'h51edc505c505);
    Sync_test(2'b10,	2'b10,	2'b0,	`WORD_SIZE'h1738,	48'hc50593b593b5);
    Sync_test(2'b10,	2'b0,	2'b11,	`WORD_SIZE'h1e2,	48'h51edc50593b5);
    Sync_test(2'b11,	2'b10,	2'b0,	`WORD_SIZE'h1aa0,	48'hc50593b551ed);
    Sync_test(2'b10,	2'b0,	2'b10,	`WORD_SIZE'h8231,	48'h93b5c50593b5);
    Sync_test(2'b10,	2'b11,	2'b0,	`WORD_SIZE'h3113,	48'hc50551ed93b5);
    Sync_test(2'b10,	2'b10,	2'b10,	`WORD_SIZE'hea00,	48'h93b593b593b5);
    Sync_test(2'b0,	2'b1,	2'b10,	`WORD_SIZE'h4117,	48'h93b58c19c505);
    Sync_test(2'b11,	2'b0,	2'b0,	`WORD_SIZE'h8fa6,	48'hc505c50551ed);
    Sync_test(2'b0,	2'b10,	2'b11,	`WORD_SIZE'hbca,	48'h51ed93b5c505);
    Sync_test(2'b11,	2'b0,	2'b11,	`WORD_SIZE'ha147,	48'h51edc50551ed);
    Sync_test(2'b0,	2'b0,	2'b10,	`WORD_SIZE'h66f2,	48'h93b5c505c505);
    Sync_test(2'b0,	2'b11,	2'b1,	`WORD_SIZE'h1d65,	48'h8c1951edc505);
    Sync_test(2'b11,	2'b0,	2'b10,	`WORD_SIZE'h8acc,	48'h93b5c50551ed);
    Sync_test(2'b1,	2'b0,	2'b11,	`WORD_SIZE'hbe54,	48'h51edc5058c19);
    Sync_test(2'b11,	2'b1,	2'b1,	`WORD_SIZE'h271c,	48'h8c198c1951ed);
    Sync_test(2'b10,	2'b11,	2'b0,	`WORD_SIZE'ha23f,	48'hc50551ed93b5);

    Reset_test;

    $display("Passed = %0d, Failed = %0d", Passed, Failed);	
    $finish;
end



endmodule // RF_tb




