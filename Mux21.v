module Mux21	#(parameter BUS_WIDTH=8)
				 (clk, ctl, in_a, in_b, out);
	
	output reg	[BUS_WIDTH-1:0]	out;
	
	input						clk;
	input 		[BUS_WIDTH-1:0]	in_a;
	input 		[BUS_WIDTH-1:0]	in_b;
	input						ctl;
	
	always @ (ctl, in_a, in_b) begin
		if(ctl == 1'b0) begin
			out <= in_a;
		end else begin
			out <= in_b;
		end
	end
endmodule