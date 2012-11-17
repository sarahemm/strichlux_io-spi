module IOSPIManagementController(clk_in, n_reset, divisor, tx_go, tx_done,
								 spi_n_ss_core, spi_n_ss_intf,
								 tx_buffer, rx_buffer,
								 io_mode, status_grn, status_red);
	
	input				clk_in;
	input				n_reset;
	output reg	[11:0]	divisor;
	output reg			tx_go;
	input				tx_done;
	output reg			spi_n_ss_core;
	output reg			spi_n_ss_intf;
	output reg	[7:0]	tx_buffer;
	input		[7:0]	rx_buffer;
	output reg	[1:0]	io_mode;
	output reg			status_grn;
	output reg			status_red;
	
	reg	[2:0]	state;
	
	`define IDLE				3'b000
	
	`define IOMODE_MGMT			2'b00	// not yet initialized
	`define IOMODE_IN			2'b01	// configured as input module
	`define IOMODE_OUT			2'b10	// configured as output module
	`define IOMODE_FAULT		2'b11	// fault, module halted
	
	initial begin
		state	<= `IDLE;
		io_mode <= `IOMODE_OUT;
	end
	
	always @ (negedge clk_in) begin
		if(n_reset == 1'b0) begin
			state 		<= `IDLE;
			io_mode		<= `IOMODE_OUT;
		end
		case (state)
			`IDLE: begin
				status_grn	<= 1'b0;
				status_red	<= 1'b1;
				io_mode		<= `IOMODE_OUT;
			end
		endcase
	end
endmodule