module IOSPITXInterface(clk_in, n_reset, divisor, tx_go, tx_done,
						spi_sclk, spi_miso, spi_mosi,
						tx_buffer, rx_buffer);
	
	input				clk_in;
	input				n_reset;
	input		[11:0]	divisor;
	input				tx_go;
	output reg			tx_done;
	output reg			spi_sclk;
	input				spi_miso;
	output reg			spi_mosi;
	output reg	[7:0]	rx_buffer;
	input		[7:0]	tx_buffer;
	
	reg			[3:0]	bit_nbr;
	wire				spi_sclk_en;
	
	ClockDivider #(12) spi_clkdiv(clk_in, spi_sclk_en, divisor);
	
	initial begin
		tx_done			<= 1'b0;
		bit_nbr			<= 1'b0;
		spi_mosi		<= 1'b0;
		spi_sclk		<= 1'b0;
	end
	
	always @ (posedge clk_in) begin
		if(n_reset == 1'b0) begin
			tx_done			<= 1'b0;
			bit_nbr			<= 1'b0;
			spi_mosi		<= 1'b0;
			spi_sclk		<= 1'b0;
		end
		if(!tx_go) spi_sclk <= 1'b0;
		if(tx_done && !tx_go) tx_done <= 1'b0;
		if(tx_go && !tx_done) begin
			if(spi_sclk_en) begin
				if(!spi_sclk && bit_nbr > 0) begin
					spi_sclk	<= 1'b1;
					rx_buffer[8-bit_nbr] <= spi_miso;
				end else begin
					// bit "0" is purely advance setup for the real first bit, 1
					if(bit_nbr > 0) spi_sclk <= 1'b0;
					bit_nbr		 <= bit_nbr + 1;
					spi_mosi	 <= tx_buffer[7-bit_nbr];
					if(bit_nbr == 8) begin
						tx_done	 <= 1'b1;
						spi_sclk <= 1'b0;
						spi_mosi <= 1'b0;
						bit_nbr  <= 1'b0;
					end
				end
			end
		end
	end
endmodule