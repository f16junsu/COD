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

	input [`kNumCoins-1:0] i_input_coin;
	input [`kNumItems-1:0] i_select_item;
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

	// output types
	reg [`kNumItems-1:0] o_available_item;
	reg [`kNumItems-1:0] o_output_item;
	reg [`kReturnCoins-1:0] o_return_coin;
	reg [`kTotalBits-1:0] o_current_total;

	// Internal states. You may add your own reg variables.
	reg [`kTotalBits-1:0] current_total; // state
	reg return_triggered; // state
	reg [`kNumItems-1:0] selected_item; // state;
	// reg [`kItemBits-1:0] num_items [`kNumItems-1:0];
	reg [`kCoinBits-1:0] num_coins [`kNumCoins-1:0]; // state


	// Combinational circuit for the next states
	always @(*) begin
		;
	end
	// Combinational circuit for the output
	always @(*) begin
		o_available_item = (current_total >= kkItemPrice[3]) ? 4'b1111 :
							(current_total >= kkItemPrice[2]) ? 4'b0111 :
							(current_total >= kkItemPrice[1]) ? 4'b0011 :
							(current_total >= kkItemPrice[0]) ? 4'b0001 :
							0;
		o_output_item = selected_item;
		o_return_coin = (return_triggered) ? num_coins[0] + num_coins[1] +num_coins[2] : 0;
		o_current_total = current_total;
	end


	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// reset all states.
			current_total <= 0;
			return_triggered <= 0;
			selected_item <= 0;
			num_coins[0] <= 0;
			num_coins[1] <= 0;
			num_coins[2] <= 0;
 		end
		else begin
			if (i_input_coin) begin
				case (i_input_coin)
					3'b100: begin
						num_coins[2] <= num_coins[2] + 1;
						current_total <= current_total + kkCoinValue[2];
					end
					3'b010: begin
						current_total <= current_total + kkCoinValue[1];
						if (num_coins[1]) begin
							num_coins[2] <= num_coins[2] + 1;
							num_coins[1] <= 0;
						end
						else num_coins[1] <= 1;
					end
					3'b001: begin
						current_total <= current_total + kkCoinValue[0];
						if (num_coins[0] == 4) begin
							num_coins[0] <= 0;
							if (num_coins[1]) begin
								num_coins[2] <= num_coins[2] + 1;
								num_coins[1] <= 0;
							end
							else num_coins[1] <= 1;
						end
						else num_coins[0] <= num_coins[0] + 1;
					end
				endcase
				return_triggered <= 0;
				selected_item <= 0;
			end
			else if (i_select_item) begin
				case (i_select_item)
					4'b1000: begin
						if (current_total >= kkItemPrice[3]) begin
							current_total <= current_total - kkItemPrice[3];
							return_triggered <= 0;
							selected_item <= 4'b1000;
							num_coins[2] <= num_coins[2] - 2;
						end
						else begin
							return_triggered <= 0;
							selected_item <= 0;
						end
					end
					4'b0100: begin
						if (current_total >= kkItemPrice[2]) begin
							current_total <= current_total - kkItemPrice[2];
							return_triggered <= 0;
							selected_item <= 4'b0100;
							num_coins[2] <= num_coins[2] - 1;
						end
						else begin
							return_triggered <= 0;
							selected_item <= 0;
						end
					end
					4'b0010: begin
						if (current_total >= kkItemPrice[1]) begin
							current_total <= current_total - kkItemPrice[1];
							return_triggered <= 0;
							selected_item <= 4'b0010;
							if (num_coins[1]) num_coins[1] <= 0;
							else begin
								num_coins[2] <= num_coins[2] - 1;
								num_coins[1] <= 1;
							end
						end
						else begin
							return_triggered <= 0;
							selected_item <= 0;
						end
					end
					4'b0001: begin
						if (current_total >= kkItemPrice[0]) begin
							current_total <= current_total - kkItemPrice[0];
							return_triggered <= 0;
							selected_item <= 4'b0001;
							if (num_coins[0] == 4) num_coins[0] <= 0;
							else if (num_coins[1]) begin
								num_coins[1] <= 0;
								num_coins[0] <= num_coins[0] + 1;
							end
							else begin
								num_coins[2] <= num_coins[2] - 1;
								num_coins[1] <= 1;
								num_coins[0] <= num_coins[0] + 1;
							end
						end
						else begin
							return_triggered <= 0;
							selected_item <= 0;
						end
					end
				endcase
			end
			else if (i_trigger_return) begin
				current_total <= 0;
				return_triggered <= 1;
				selected_item <= 0;
			end
		end
	end

endmodule
