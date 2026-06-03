/*
* Simple GPIO Output IP (Write-Only with readback)
* Memory-mapped register at IO_GPIO_bit = 3
* Address is 0x00400020
*/

module gpio_output(
       input clk,
       input resetn,
       input gpio_sel, // High when CPU is using this IP
       input gpio_we, // Write Enable
       input [31:0] gpio_wdata, // Data written by CPU
       output reg [31:0] gpio_rdata, // Data read by CPU

      // External Hardware Output

       output [31:0] gpio_out); // Connection to outer ports

       reg [31:0] gpio_reg; // Latching the value      

       // Write Logic
       always@(posedge clk) begin
	  if(~resetn)
	     gpio_reg <= 32'd0;
          else begin
             if(gpio_sel && gpio_we)
                gpio_reg <= gpio_wdata;
	  end
       end

       // Readback Logic
       // When CPU read this IP, return the last value stored in the register
       // Otherwise, drive the read bus to 0
       always@(*) begin
	  if(gpio_sel)
             gpio_rdata <= gpio_reg;
          else
             gpio_rdata <= 32'd0;
       end

       // Drive External Logic
       assign gpio_out = gpio_reg;
endmodule
