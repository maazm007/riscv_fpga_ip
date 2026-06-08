module spi_master(
	input clk,
	input resetn,
	input sel,
	input we,
	input [31:0] addr,
	input [31:0] wdata,           // Data from CPU
	output reg [31:0] rdata,      // Data back to CPU
	output reg SCLK,              // Serial Clcok
	output MOSI,                  // Master sends data to Slave
	input MISO,                   // Master receive data from Slave
	output reg CS_N               // Chip Select
);

// --- Register Address Offset ---
localparam REG_CTRL    = 2'b00;  // addr[3:2] = 00 > Offset 0x00
localparam REG_TXDATA  = 2'b01;  // addr[3:2] = 01 > Offset 0x04
localparam REG_RXDATA  = 2'b10;  // addr[3:2] = 10 > Offset 0x08
localparam REG_STATUS  = 2'b11;  // addr[3:2] = 11 > Offset 0x0C

// --- 4 Registers ---
reg [31:0] ctrl_reg; // Enable, Start, CLKDIV
reg [7:0] txdata_reg;// Byte to transmit
reg [7:0] rxdata_reg;// Byte to receive
reg busy; // Status Bit 0 = 1 (while transferring)
reg done; // Status But 1 = 1 (when transfer is done)

// Intermediate Signals from CTRL
wire ctrl_en           = ctrl_reg[0]; // Enable Bit
wire ctrl_start        = ctrl_reg[1]; // Start Bit
wire [7:0] ctrl_clkdiv = ctrl_reg[15:8]; // Clock Divider

// Internal Shift Registers
reg [7:0] tx_shift; // hold byte being sent, MSB first
reg [7:0] rx_shift; // hold byte being received, from LSB

// Register Select
wire [1:0] reg_sel = addr[3:2];

// Counters
reg [3:0] bit_count;
reg [7:0] clk_cnt;

// State Machines
localparam IDLE       = 2'b00;
localparam START      = 2'b01;
localparam TRANSFER   = 2'b10;
localparam FINISH     = 2'b11;
reg [1:0] state;

// --- SCLK Edge Detection ---
// When clk_cnt reaches clkdiv, SCLK toggles

wire sclk_edge = (clk_cnt == ctrl_clkdiv);
wire sclk_rising = sclk_edge && (SCLK == 1'b0);
wire sclk_falling = sclk_edge && (SCLK == 1'b1);

// MOSI is driven by MSB of tx_shift
assign MOSI = tx_shift[7];

// --- Write Logic ---
// Only ctrl_reg and txdata_reg are written here

always@(posedge clk) begin
	if(~resetn) begin
		ctrl_reg <= 32'd0;
		txdata_reg <= 8'd0;
	end
	else begin
	       	if (sel && we) begin
		case(reg_sel)
		REG_CTRL: begin 
	       	ctrl_reg <= wdata;
		if(busy)
			ctrl_reg[1] <= 1'b0; // Ignore new Start if busy = 1
		end
		REG_TXDATA: txdata_reg <= wdata[7:0];
		endcase
		end
	        
		// Auto-Clear Start
		if(state == START)
			ctrl_reg[1] <= 1'b0; // Clear the Start Bit
	end
end

// --- Done Bit ---
always@(posedge clk) begin
	if(~resetn)
		done <= 1'b0;
	else if (state == FINISH)
		done <= 1'b1;
	else if (sel && we && (reg_sel == REG_STATUS) && wdata[1])
		done <= 1'b0;
end

// --- State Machine ---
always@(posedge clk) begin
	if(~resetn) begin
		state <= IDLE;
		bit_count <= 4'b0;
		tx_shift <= 8'b0;
		rx_shift <= 8'b0;
		rxdata_reg <= 8'b0;
		clk_cnt <= 8'b0;
		SCLK <= 1'b0;
		CS_N <= 1'b1;
		busy <= 1'b0;
	end
	else begin
		case(state)
		// IDLE: Wait for EN = 1 and START = 1
		IDLE: begin
			SCLK <= 1'b0;
			CS_N <= 1'b1;
			clk_cnt <= 8'b0;
			busy <= 1'b0;

			if(ctrl_en && ctrl_start && (~busy))
				state <= START;
		end

		// START: pull CS low, load shift reg
		START: begin
			CS_N <= 1'b0;
			tx_shift <= txdata_reg;
			rx_shift <= 8'b0;
			bit_count <= 4'b0;
			busy <= 1'b1;
			clk_cnt <= 8'b0;
			state <= TRANSFER;
		end

		// TRANSFER: send/receive 8 bits
		TRANSFER: begin
			if(sclk_edge) begin
				SCLK <= ~SCLK;
				clk_cnt <= 8'b0;
				
				if(sclk_rising) begin
				// Rising Edge: sample MISO into rx_shift
				// Shift existing bit left, new bit at LSB
				rx_shift <= {rx_shift[6:0], MISO};

				if(bit_count == 4'd7)
					state <= FINISH;
				else
					bit_count <= bit_count + 1;
				end

				if(sclk_falling) begin
				// Falling Edge: shift TX left
				// Next Bit tx[7] ready on MOSI
				tx_shift <= {tx_shift[6:0], 1'b0};
				end
			end
			else
				clk_cnt <= clk_cnt + 1'b1;
		end

		// FINISH: deassert CS, save the received byte
		FINISH: begin
			SCLK <= 1'b0;
			CS_N <= 1'b1;
			rxdata_reg <= rx_shift;
			busy <= 1'b0;
			state <= IDLE;
		end
	endcase
	end
end

// --- Read Logic ---
always@(*)
begin
	case(reg_sel)
	REG_CTRL: rdata = ctrl_reg;
	REG_TXDATA: rdata = {24'b0, txdata_reg};
	REG_RXDATA: rdata = {24'b0, rxdata_reg};
	REG_STATUS: rdata = {29'b0, ~busy, done, busy};
	default: rdata = 32'b0;
	endcase
end
endmodule

