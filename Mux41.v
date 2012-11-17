module Mux41	#(parameter BUS_WIDTH=8)
				 (clk, ctl, in_a, in_b, in_c, in_d, out);
	
	output reg	[BUS_WIDTH-1:0]	out;
	
	input						clk;
	input 		[BUS_WIDTH-1:0]	in_a;
	input 		[BUS_WIDTH-1:0]	in_b;
	input 		[BUS_WIDTH-1:0]	in_c;
	input 		[BUS_WIDTH-1:0]	in_d;
	input		[1:0]			ctl;
	
	always @ (in_a, in_b, in_c, in_d, ctl) begin
		case (ctl)
			2'b00: begin
				out = in_a;
			end
			2'b01: begin
				out = in_b;
			end
			2'b10: begin
				out = in_c;
			end
			2'b11: begin
				out = in_d;
			end
		endcase
	end
endmodule