module ClockDivider #(parameter DIVISOR_WIDTH=32)
					 (clk_in, clken_out, clk_divisor);
	input						clk_in;
	output reg 					clken_out;
	input	[DIVISOR_WIDTH-1:0] clk_divisor;
	reg 	[DIVISOR_WIDTH-1:0]	clk_accumulator;
	
	initial begin
		clk_accumulator <= 1'b0;
	end
	
	always @(negedge clk_in) begin
		clk_accumulator <= clk_accumulator + 1'b1;
		// reset accum back to zero if accum > divis
		// this avoids really long delays as we wrap around during a divisor change
		if(clk_accumulator > clk_divisor) clk_accumulator <= 1'b0;
		if(clk_accumulator == clk_divisor) begin
			clken_out <= 1'b1;
			clk_accumulator <= 1'b0;
		end else begin
			clken_out <= 1'b0;
		end
	end
endmodule