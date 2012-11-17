module IOSPIOutputController(clk_in, n_reset, divisor, tx_go, tx_done,
							 spi_n_ss_core, spi_n_ss_intf,
						     tx_buffer, rx_buffer);
	
	input				clk_in;	input				n_reset;
	output reg	[11:0]	divisor;
	output reg			tx_go;
	input				tx_done;
	output reg			spi_n_ss_core;
	output reg			spi_n_ss_intf;
	output reg	[7:0]	tx_buffer;
	input		[7:0]	rx_buffer;
	
	reg			[3:0]	state;
	reg			[3:0]	next_state;
	reg			[12:0]	next_channel;
	reg			[32:0]	startup_delay;
	reg			[7:0]	data_to_output;
	
	`define	SPI_OUT_INIT				4'b0000
	`define SPI_OUT_TXDATA				4'b0001
	`define SPI_OUT_LATCH				4'b0010
	`define SPI_OUT_WAIT_LAT			4'b0011
	`define SPI_OUT_IPD					4'b0100
	`define SPI_OUT_INITCORE_CMD		4'b0101
	`define SPI_OUT_INITCORE_ARG		4'b0110
	`define SPI_OUT_INITCORE_FINISH 	4'b0111
	`define SPI_OUT_DATAFETCH_INIT		4'b1000
	`define SPI_OUT_DATAFETCH_CMD		4'b1001
	`define SPI_OUT_DATAFETCH_ARG		4'b1010
	`define SPI_OUT_DATAFETCH_FINISH	4'b1011
	`define SPI_OUT_WAIT_TXDONE			4'b1111
	
	`define CORE_CMD_SETPTR		8'b00000111
	`define CORE_CMD_READNEXT	8'b00000100
	
	`define SPI_SPEED_CORE		12'b000000000001
	`define SPI_SPEED_IO		12'b000000101000
	
	initial begin
		next_channel	<= 8'b00000000;
		tx_go			<= 1'b0;
		state			<= `SPI_OUT_INIT;
		divisor			<= `SPI_SPEED_IO;
		spi_n_ss_core	<= 1'b1;
		spi_n_ss_intf	<= 1'b1;
		startup_delay   <= 1'b0;
	end
	
	always @ (negedge clk_in) begin
		if(n_reset == 1'b0) begin
			tx_go			<= 1'b0;
			next_channel	<= 8'b00000000;
			state 			<= `SPI_OUT_INIT;
			divisor			<= `SPI_SPEED_IO;
			spi_n_ss_core	<= 1'b1;
			spi_n_ss_intf	<= 1'b1;
			startup_delay   <= 1'b0;
		end
		case (state)
			`SPI_OUT_INIT: begin
				divisor		  <= `SPI_SPEED_IO;
				spi_n_ss_core <= 1'b1;
				next_channel  <= 1'b1;
				startup_delay <= startup_delay + 32'd1;
				if(startup_delay > 32'd148) begin
					spi_n_ss_intf <= 1'b0;
				end else begin
					spi_n_ss_intf <= 1'b1;
				end
				if(startup_delay == 32'd150) begin
					state <= `SPI_OUT_LATCH;
				end
			end
			`SPI_OUT_TXDATA: begin
				tx_buffer[6:0] 	<= data_to_output[7:1];
				// LPD8806 takes 7-bit data, MSB must be 1
				tx_buffer[7]	<= 1'b1;
				next_channel 	<= next_channel + 1;
				tx_go		 	<= 1'b1;
				if(next_channel + 1 < 480) begin
					next_state		<= `SPI_OUT_DATAFETCH_INIT;
				end else begin
					next_state		<= `SPI_OUT_LATCH;
					next_channel	<= 1'b0;
				end
				state		 <= `SPI_OUT_WAIT_TXDONE;
			end
			`SPI_OUT_LATCH: begin
				next_channel <= next_channel + 1;
				tx_buffer <= 8'b00000000;
				tx_go     <= 1'b1;
				state	  <= `SPI_OUT_WAIT_LAT;
			end
			`SPI_OUT_WAIT_LAT: begin
				if(tx_done == 1'b1) begin
					tx_go <= 1'b0;
					if(next_channel < 5) begin
						state <= `SPI_OUT_LATCH;
					end else begin
						next_channel <= 0;
						state <= `SPI_OUT_IPD;
					end
				end
			end
			`SPI_OUT_IPD: begin
				spi_n_ss_intf     <= 1'b1;
				next_channel      <= next_channel + 1;
				if(next_channel > 4000) begin
					next_channel  <= 0;
					divisor		  <= `SPI_SPEED_CORE;
					spi_n_ss_core <= 1'b0;
					state 		  <= `SPI_OUT_INITCORE_CMD;
				end
			end
			`SPI_OUT_INITCORE_CMD: begin
				tx_buffer	<= `CORE_CMD_SETPTR;
				tx_go		<= 1'b1;
				next_state	<= `SPI_OUT_INITCORE_ARG;
				state		<= `SPI_OUT_WAIT_TXDONE;
			end
			`SPI_OUT_INITCORE_ARG: begin
				tx_buffer	<= 8'b00000000;
				tx_go		<= 1'b1;
				next_state	<= `SPI_OUT_INITCORE_FINISH;
				state		<= `SPI_OUT_WAIT_TXDONE;
			end
			`SPI_OUT_INITCORE_FINISH: begin
				spi_n_ss_core 	<= 1'b1;
				state		  	<= `SPI_OUT_DATAFETCH_INIT;
			end
			`SPI_OUT_DATAFETCH_INIT: begin
				spi_n_ss_intf	<= 1'b1;
				state			<= `SPI_OUT_DATAFETCH_CMD;
			end
			`SPI_OUT_DATAFETCH_CMD: begin
				tx_buffer		<= `CORE_CMD_READNEXT;
				spi_n_ss_core 	<= 1'b0;
				tx_go			<= 1'b1;
				divisor			<= `SPI_SPEED_CORE;
				next_state		<= `SPI_OUT_DATAFETCH_ARG;
				state			<= `SPI_OUT_WAIT_TXDONE;
			end
			`SPI_OUT_DATAFETCH_ARG: begin
				tx_buffer	<= 8'b00000000;
				tx_go		<= 1'b1;
				next_state	<= `SPI_OUT_DATAFETCH_FINISH;
				state		<= `SPI_OUT_WAIT_TXDONE;
			end
			`SPI_OUT_DATAFETCH_FINISH: begin
				data_to_output	<= rx_buffer;
				divisor			<= `SPI_SPEED_IO;
				spi_n_ss_core	<= 1'b1;
				spi_n_ss_intf	<= 1'b0;
				state			<= `SPI_OUT_TXDATA;
			end
			`SPI_OUT_WAIT_TXDONE: begin
				if(tx_go == 1'b1) begin
					// first wait for done to go high, and lower go
					if(tx_done == 1'b1) begin
						tx_go <= 1'b0;
					end
				end else begin
					// now we've lowered go, we wait for done to go low to complete the handshake
					if(tx_done == 1'b0) begin
						state 		<= next_state;
						next_state	<= 2'b00;
					end
				end
			end
		endcase
	end
endmodule