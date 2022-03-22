// Title         : vending_machine.v
// Author      : Hunjun Lee (hunjunlee7515@snu.ac.kr), Suheon Bae (suheon.bae@snu.ac.kr)

`include "vending_machine_def.v"

module vending_machine (

	clk,							// Clock signal
	reset_n,						// Reset signal (active-low)

	i_input_coin,				// coin is inserted.
	i_select_item,				// item is selected.
	i_trigger_return,			// change-return is triggered

	o_available_item,			// Sign of the item availability
	o_output_item,			   // Sign of the item withdrawal
	o_return_coin,			   // Sign of the coin return
	o_current_total
);

	// Ports Declaration
	input clk;
	input reset_n;

	input [`kNumCoins-1:0] i_input_coin; // 3bit
	input [`kNumItems-1:0] i_select_item; // 4bit
	input i_trigger_return;

	output [`kNumItems-1:0] o_available_item;
	output [`kNumItems-1:0] o_output_item;
	output [`kReturnCoins-1:0] o_return_coin;
	output [`kTotalBits-1:0] o_current_total;


	// Net constant values (prefix kk & CamelCase)
	wire [31:0] kkItemPrice [`kNumItems-1:0];	// Price of each item
	wire [31:0] kkCoinValue [`kNumCoins-1:0];	// Value of each coin
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;

	// Internal states. You may add your own reg variables.

	// reg [`kItemBits-1:0] num_items [`kNumItems-1:0]; //use if needed
	// reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0]; //use if needed

	// Outputs types
	reg [`kNumItems-1:0] o_available_item; // state
	reg [`kNumItems-1:0] o_output_item; // state
	reg [`kReturnCoins-1:0] o_return_coin; // state
	reg [`kTotalBits-1:0] o_current_total; // state


	// buffers
	reg [`kNumItems-1:0] o_available_item_buffer;
	reg [`kNumItems-1:0] o_output_item_buffer;
	reg [`kReturnCoins-1:0] o_return_coin_buffer;
	reg [`kTotalBits-1:0] o_current_total_buffer;

	// Combinational circuit for the next states
	always @(*) begin
		// if input coin
		case (i_input_coin)
			3'b100: o_current_total_buffer = o_current_total + kkCoinValue[2];
			3'b010: o_current_total_buffer = o_current_total + kkCoinValue[1];
			3'b001: o_current_total_buffer = o_current_total + kkCoinValue[0];
			default: o_current_total_buffer = o_current_total;
		endcase

		// case if the selected item is soldable
		case (o_available_item & i_select_item)
			4'b1000: {o_output_item_buffer, o_current_total_buffer} = {i_select_item, o_current_total - kkItemPrice[3]};
			4'b0100: {o_output_item_buffer, o_current_total_buffer} = {i_select_item, o_current_total - kkItemPrice[2]};
			4'b0010: {o_output_item_buffer, o_current_total_buffer} = {i_select_item, o_current_total - kkItemPrice[1]};
			4'b0001: {o_output_item_buffer, o_current_total_buffer} = {i_select_item, o_current_total - kkItemPrice[0]};
			default: o_output_item_buffer = 0;
		endcase

		// available item
		o_available_item_buffer = (o_current_total_buffer >= kkItemPrice[3]) ? 4'b1111 :
								  (o_current_total_buffer >= kkItemPrice[2]) ? 4'b0111 :
								  (o_current_total_buffer >= kkItemPrice[1]) ? 4'b0011 :
								  (o_current_total_buffer >= kkItemPrice[0]) ? 4'b0001 :
								  0;

		// when return triggered
		if (i_trigger_return) begin
			o_return_coin_buffer = 0; // return coin initialize
			while (o_current_total_buffer) begin
				if (o_current_total_buffer >= kkCoinValue[2])
					o_current_total_buffer = o_current_total_buffer - kkCoinValue[2];
				else if (o_current_total_buffer >= kkCoinValue[1])
					o_current_total_buffer = o_current_total_buffer - kkCoinValue[1];
				else o_current_total_buffer = o_current_total_buffer - kkCoinValue[0];
				o_return_coin_buffer = o_return_coin_buffer + 1;
			end
			o_available_item_buffer = 0;
		end
	end

	// Combinational circuit for the output
	always @(*) begin
		;// state directly goes to output
	end


	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			o_available_item <= 0;
			o_output_item <= 0;
			o_return_coin <= 0;
			o_current_total <= 0;
		end
		else begin
			o_available_item <= o_available_item_buffer;
			o_output_item <= o_output_item_buffer;
			o_return_coin <= o_return_coin_buffer;
			o_current_total <= o_current_total_buffer;
		end
	end

endmodule