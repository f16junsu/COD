// Title         : vending_machine_TB.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr)

`timescale 100ps / 100ps

`include "vending_machine_def.v"

module vending_machine_tb;


//Internal signal declaration
reg clk;
reg reset_n;
reg [2:0]i_input_coin;
reg [3:0]i_select_item;
reg i_trigger_return;
wire [3:0]o_available_item;
wire [3:0]o_output_item;
wire [9:0]o_return_coin;
wire [31:0]o_current_total;

integer Passed;
integer Failed;

// Unit Under Test port map
	vending_machine UUT (
		.clk(clk),
		.reset_n(reset_n),
		.i_input_coin(i_input_coin),
		.i_select_item(i_select_item),
		.i_trigger_return(i_trigger_return),
		.o_available_item(o_available_item),
		.o_output_item(o_output_item),
		.o_return_coin(o_return_coin),
		.o_current_total(o_current_total));

// clock signal
initial clk <= 0;
always #50 clk <= ~clk; // a clock cycle: # 100, a half cycle: # 50

initial begin
	// Reset the device
	reset_n = 1;
	#50 reset_n = 0;
	#100 reset_n = 1;

	// Initialize input signals
	i_input_coin[0] = 0;
	i_input_coin[1] = 0;
	i_input_coin[2] = 0;
	i_select_item[0] = 0;
	i_select_item[1] = 0;
	i_select_item[2] = 0;
	i_select_item[3] = 0;
	i_trigger_return = 0;


	# 150; // Wait until the output signals are stable.
	Insert100Coin();
	Insert100Coin();
	Insert100Coin();
	Insert100Coin();
	Insert100Coin(); // 500

	Insert500Coin();
	Insert500Coin(); // 1500

	Insert1000Coin();
	Insert1000Coin();
	Insert1000Coin();
	Insert1000Coin(); // 5500

	Select1stItem();
	Select1stItem(); // 4700

	Select2ndItem();
	Select2ndItem(); // 3700

	Select3rdItem(); // 2700

	Select4thItem(); // 700

	Insert100Coin();
	Insert100Coin();
	Insert100Coin();
	Insert500Coin();
	Insert500Coin();
	Insert500Coin();
	Insert1000Coin();
	Insert1000Coin();
	Insert1000Coin(); //5500

	TriggerReturn(); // 0

	#10000 $finish(0);
end

initial begin
    Passed = 0;
    Failed = 0;
    #600 //600
    general_check(4'b0000, 4'b0000, 100);
    #200 //800
    general_check(4'b0000, 4'b0000, 200);
    #200 //1000
    general_check(4'b0000, 4'b0000, 300);
    #200 //1200
    general_check(4'b0001, 4'b0000, 400);
    #200 //1400
    general_check(4'b0011, 4'b0000, 500);
    #200 //1600
    general_check(4'b0111, 4'b0000, 1000);
    #200 //1800
    general_check(4'b0111, 4'b0000, 1500);
    #200 //2000
    general_check(4'b1111, 4'b0000, 2500);
    #200 //2200
    general_check(4'b1111, 4'b0000, 3500);
    #200 //2400
    general_check(4'b1111, 4'b0000, 4500);
    #200 //2600
    general_check(4'b1111, 4'b0000, 5500);
    #100 //2700
    general_check(4'b1111, 4'b0001, 5100);
    #200 //2900
    general_check(4'b1111, 4'b0001, 4700);
    #200 //3100
    general_check(4'b1111, 4'b0010, 4200);
    #200 //3300
    general_check(4'b1111, 4'b0010, 3700);
    #200 //3500
    general_check(4'b1111, 4'b0100, 2700);
    #200 //3700
    general_check(4'b0011, 4'b1000, 700);
    #200 //3900
    general_check(4'b0011, 4'b0000, 800);
    #200 //4100
    general_check(4'b0011, 4'b0000, 900);
    #200 //4300
    general_check(4'b0111, 4'b0000, 1000);
    #200 //4500
    general_check(4'b0111, 4'b0000, 1500);
    #200 //4700
    general_check(4'b1111, 4'b0000, 2000);
    #200 //4900
    general_check(4'b1111, 4'b0000, 2500);
    #200 //5100
    general_check(4'b1111, 4'b0000, 3500);
    #200 //5300
    general_check(4'b1111, 4'b0000, 4500);
    #200 //5500
    general_check(4'b1111, 4'b0000, 5500);
    #200 //5700
    general_check(4'b0000, 4'b0000, 0);
    return_check(6);
    #200 //5900
    general_check(4'b0000, 4'b0000, 0);

    $display("Passed = %0d, Failed = %0d", Passed, Failed);
end
task general_check;

    input [`kNumItems-1:0] available_item;
    input [`kNumItems-1:0] output_item;
    input [`kTotalBits-1:0] current_total;
    begin
        if(available_item == o_available_item && output_item == o_output_item && current_total == o_current_total) begin
            Passed = Passed + 1;
            $display("PASSED");
        end
        else begin
            Failed = Failed + 1;
            $display("FAILED at %0d", $time, "ns");
            $display("Correct ans=> o_available_item: 4'b%b, o_output_item: 4'b%b, o_current_total: %0d", available_item, output_item, current_total);
        end
    end
endtask
task return_check;

    input [`kNumCoins-1:0] return_coin;
    begin
        if(return_coin == o_return_coin) begin
            Passed = Passed + 1;
            $display("PASSED");
        end
        else begin
            Failed = Failed + 1;
            $display("FAILED at %0d", $time, "ns");
            $display("Correct ans=> o_return_coin: %0d", return_coin);
        end
    end
endtask

// User's Action
task Insert100Coin;
begin
	# 100 i_input_coin[0] = 1;
	# 100 i_input_coin[0] = 0;	// After one cycle, deactivate the signal
end
endtask

task Insert500Coin;
begin
	# 100 i_input_coin[1] = 1;
	# 100 i_input_coin[1] = 0;	// After one cycle, deactivate the signal
end
endtask

task Insert1000Coin;
begin
	# 100 i_input_coin[2] = 1;
	# 100 i_input_coin[2] = 0;	// After one cycle, deactivate the signal
end
endtask

task Select1stItem;
begin
	# 100 i_select_item[0] = 1;
	# 100 i_select_item[0] = 0;	// After one cycle, deactivate the signal
end
endtask

task Select2ndItem;
begin
	# 100 i_select_item[1] = 1;
	# 100 i_select_item[1] = 0;	// After one cycle, deactivate the signal
end
endtask

task Select3rdItem;
begin
	# 100 i_select_item[2] = 1;
	# 100 i_select_item[2] = 0;	// After one cycle, deactivate the signal
end
endtask

task Select4thItem;
begin
	# 100 i_select_item[3] = 1;
	# 100 i_select_item[3] = 0; 	// After one cycle, deactivate the signal
end
endtask

task TriggerReturn;
begin
	# 100 i_trigger_return = 1;
end
endtask

endmodule
