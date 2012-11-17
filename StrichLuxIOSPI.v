module StrichLuxIOSPI(intf_en, i2c_scl, i2c_sda, spi_sclk, spi_n_ss, spi_miso, spi_mosi, status_red, status_grn, intf_dir_miso, intf_dir_mosi);
	output 			intf_en;
	
	inout			i2c_scl;
	inout			i2c_sda;
	output			spi_sclk;
	output	[1:0]	spi_n_ss;
	input			spi_miso;
	output			spi_mosi;
	
	output			status_red;
	output			status_grn;
	
	output			intf_dir_miso;
	output			intf_dir_mosi;
	
	wire			n_reset;
	wire			clk_in;
	
	wire			tx_go;
	wire			tx_done;
	wire	[1:0]	io_mode;
	
	wire	[7:0]	rx_buffer;
	
	wire	[11:0]	divisor;
	wire	[11:0]	divisor_mgmt;
	wire	[11:0]	divisor_in;
	wire	[11:0]	divisor_out;

	wire	[7:0]	tx_buffer;
	wire	[7:0]	tx_buffer_mgmt;
	wire	[7:0]	tx_buffer_in;
	wire	[7:0]	tx_buffer_out;
	
	`define IOMODE_MGMT			2'b00	// not yet initialized
	`define IOMODE_IN			2'b01	// configured as input module
	`define IOMODE_OUT			2'b10	// configured as output module
	`define IOMODE_FAULT		2'b11	// fault, module halted
	
	// needed only for simulation
	GSR GSR_INST(.GSR(1'b1));
	PUR PUR_INST(.PUR(1'b1));
	
	// internal oscillator
	OSCH #("19.0") osc(.STDBY(1'b0), .OSC(clk_in), .SEDSTDBY());
	
	assign n_reset		= 1'b1;	// we should pin this out eventually
	assign intf_en		= ~spi_n_ss_intf;
	assign spi_n_ss[0]	= spi_n_ss_core;
	assign spi_n_ss[1]	= spi_n_ss_intf;
	
	// TODO: support bidi
	assign intf_dir_mosi = 1'b1;
	assign intf_dir_miso = 1'b0;
	
	// MOSI muxes
	MUX41 n_ss_intf_mux(spi_n_ss_intf_mgmt, spi_n_ss_intf_in, spi_n_ss_intf_out, spi_n_ss_intf_mgmt, io_mode[0], io_mode[1], spi_n_ss_intf);
	
	Mux41 #(1)	n_ss_core_mux (clk_in, io_mode, spi_n_ss_core_mgmt, spi_n_ss_core_in, spi_n_ss_core_out, spi_n_ss_core_mgmt, spi_n_ss_core);
//	Mux41 #(1)	n_ss_intf_mux (clk_in, io_mode, spi_n_ss_intf_mgmt, spi_n_ss_intf_in, spi_n_ss_intf_out, spi_n_ss_intf_mgmt, spi_n_ss_intf);
	Mux41 #(12)	divisor_mux	  (clk_in, io_mode, divisor_mgmt,       divisor_in,       divisor_out,       divisor_mgmt,       divisor);
	Mux41 #(1)	tx_go_mux	  (clk_in, io_mode, tx_go_mgmt,         tx_go_in,	      tx_go_out,         tx_go_mgmt,         tx_go);
	Mux41 #(8)	tx_buffer_mux (clk_in, io_mode, tx_buffer_mgmt,     tx_buffer_in,     tx_buffer_out,     tx_buffer_mgmt,     tx_buffer);
	
	IOSPITXInterface intf_spi_out(	clk_in, n_reset, divisor, tx_go, tx_done,
									spi_sclk, spi_miso, spi_mosi,
									tx_buffer, rx_buffer);

	IOSPIManagementController ctl_mgmt(	clk_in, n_reset, divisor_mgmt, tx_go_mgmt, tx_done,
										spi_n_ss_core_mgmt, spi_n_ss_intf_mgmt,
										tx_buffer_mgmt, rx_buffer,
										io_mode, status_grn, status_red);
	
	IOSPIOutputController ctl_out(	clk_in, n_reset, divisor_out, tx_go_out, tx_done,
									spi_n_ss_core_out, spi_n_ss_intf_out,
									tx_buffer_out, rx_buffer);
endmodule