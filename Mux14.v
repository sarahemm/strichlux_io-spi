module Mux14	#(parameter BUS_WIDTH=8, UNSEL_LVL=1'b0)
				 (clk, ctl, in, out_a, out_b, out_c, out_d);
	
	input		[BUS_WIDTH-1:0]	in;
	input						clk;
	input		[1:0]			ctl;
	
	output reg	[BUS_WIDTH-1:0]	out_a;
	output reg	[BUS_WIDTH-1:0]	out_b;
	output reg	[BUS_WIDTH-1:0]	out_c;
	output reg	[BUS_WIDTH-1:0]	out_d;
	
	always @ (in, ctl) begin
		case (ctl)
			2'b00: begin
				out_a <= in;
				out_b <= UNSEL_LVL;
				out_c <= UNSEL_LVL;
				out_d <= UNSEL_LVL;
			end
			2'b01: begin
				out_a <= UNSEL_LVL;
				out_b <= in;
				out_c <= UNSEL_LVL;
				out_d <= UNSEL_LVL;
			end
			2'b10: begin
				out_a <= UNSEL_LVL;
				out_b <= UNSEL_LVL;
				out_c <= in;
				out_d <= UNSEL_LVL;
			end
			2'b11: begin
				out_a <= UNSEL_LVL;
				out_b <= UNSEL_LVL;
				out_c <= UNSEL_LVL;
				out_d <= in;
			end
		endcase
	end
endmodule