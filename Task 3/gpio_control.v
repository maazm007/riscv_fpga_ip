/*
* ==================================================================================================
* GPIO Control IP - Multi Register
*
* Register Map
* 	Base + 0x00 = GPIO_DATA (0x00400020)
* 	Base + 0x04 = GPIO_DIR  (0x00400024)
* 	Base + 0x08 = GPIO_READ (0x00400028)
*
* Offset decoded via mem_addr[3:2]
* 2'b00 - GPIO_DATA
* 2'b01 - GPIO_DIR
* 2'b10 - GPIO_READ
* ==================================================================================================
*/

module gpio_control(
	input clk,
	input resetn,
        input sel,
	input we,
	input [31:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata,

	// GPIO Pin Interface
	input [31:0] gpio_in,    // actual pin values from outside
	output [31:0] gpio_out,  // drive the output values
	output [31:0] gpio_oe    // output enable (1 = output |  0 = input)
);
	      

// =================================================================================================
// Internal Registers
// =================================================================================================

reg [31:0] gpio_data_reg; // Stores Output Value
reg [31:0] gpio_dir_reg;  // Stores Direction

// =================================================================================================
// Offset Decoder
// mem_addr[3:2] will pick the register
// =================================================================================================

wire [1:0] reg_sel = addr[3:2];

localparam REG_DATA = 2'b00;
localparam REG_DIR = 2'b01;
localparam REG_READ = 2'b10;

// =================================================================================================
// Write Logic - Synchronous
// =================================================================================================

always@(posedge clk) begin
	if(~resetn) begin
		gpio_data_reg <= 32'd0;
		gpio_dir_reg <= 32'd0;
	end
	else begin
		if(sel && we) begin
		case(reg_sel)
			REG_DATA: gpio_data_reg <= wdata;
			REG_DIR: gpio_dir_reg <= wdata;
		endcase
		end
	end
end

// =================================================================================================
// Read Logic - Combinational
// =================================================================================================

always@(*) begin
	case(reg_sel)
	REG_DATA: rdata = gpio_data_reg;
	REG_DIR: rdata = gpio_dir_reg;
	REG_READ: rdata = gpio_read_val; // Actual Pin State
	default: rdata = 32'd0;
	endcase
end

// =================================================================================================
// GPIO_READ value
// For Output pins (dir = 1): reflect DATA register value
// For Input Pins (dir = 0): reflect actual gpio_in value
// =================================================================================================

wire [31:0] gpio_read_val;
assign gpio_read_val = (gpio_dir_reg & gpio_data_reg) | (~gpio_dir_reg & gpio_in);

// =================================================================================================
// Output Assignments
// gpio_out: the value to drive on output pins
// gpio_oe: which pins are output (same as DIR register
// =================================================================================================

assign gpio_out = gpio_data_reg;
assign gpio_oe = gpio_dir_reg;

endmodule
