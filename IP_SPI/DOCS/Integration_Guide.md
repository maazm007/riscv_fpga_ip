## ***1️⃣ Integration Guide***  
  
*This guide explains how to integrate the SPI Master IP into the VSDSquadron RISC-V SoC. The reader is assumed to be familiar with the VSDSquadron FPGA setup and the existing ```riscv.v``` SoC structure.*  
  
### Required RTL Files  
* ```spi_master.v``` : *SPI Master IP Module*
* ```riscv.v``` : *Existing VSDSquadron SoC*
* ```ice40_stubs.v``` : *ice40 primitive stubs for simulation*  
  
### Instantiation of IP  
```verilog
`include "clockworks.v"
`include "emitter_uart.v"
`include "gpio_ctrl.v"
`include "spi_master.v"    // ← add this line
```  
  
### Add SPI Ports to SoC Module
```verilog
module SOC (
    input             RESET,
    output reg [4:0]  LEDS,
    input             RXD,
    output            TXD,
    output            SPI_SCLK,   // SPI clock to slave
    output            SPI_MOSI,   // SPI data to slave
    input             SPI_MISO,   // SPI data from slave
    output            SPI_CS_N    // SPI chip select (active low)
);
```  
  
### Add Address Decode 
```verilog
localparam IO_LEDS_bit      = 0;   // 0x400004
localparam IO_UART_DAT_bit  = 1;   // 0x400008
localparam IO_UART_CNTL_bit = 2;   // 0x400010
localparam IO_GPIO_bit      = 3;   // 0x400020
localparam IO_SPI_bit       = 4;   // 0x400040  ← add this
```  
  
### Instantiate ```spi_master.v``` inside SoC
```verilog
wire spi_sel = isIO & mem_wordaddr[IO_SPI_bit];
wire [31:0] SPI_rdata;

spi_master spi_ip (
    .clk    (clk),
    .resetn (resetn),
    .sel    (spi_sel),
    .we     (mem_wstrb),
    .addr   (mem_addr),
    .wdata  (mem_wdata),
    .rdata  (SPI_rdata),
    .SCLK   (SPI_SCLK),
    .MOSI   (SPI_MOSI),
    .MISO   (SPI_MISO),
    .CS_N   (SPI_CS_N)
);
```  
  
### Add SPI to ```rdata MUX```
```verilog
wire [31:0] IO_rdata =
    mem_wordaddr[IO_UART_CNTL_bit] ? {22'b0, !uart_ready, 9'b0} :
    mem_wordaddr[IO_GPIO_bit]      ? GPIO_rdata                 :
    mem_wordaddr[IO_SPI_bit]       ? SPI_rdata                  :
                                     32'b0;
```  

***  

## ***2️⃣ Board-level Usage*** 

### FPGA Pin Assignments  
```verilog
set_io LEDS[0]  39
set_io LEDS[1]  41
set_io LEDS[2]  40
set_io LEDS[3]  25
set_io LEDS[4]  26
set_io RESET    23
set_io TXD      4
set_io RXD      3
set_io SPI_CS_N   9
set_io SPI_SCLK   10
set_io SPI_MOSI   11
set_io SPI_MISO   12
```  
  
### Phsical Pin Connections  
| Signal   | FPGA Pin | Board Header  | Connect To |
|:--------:|:--------:|:-------------:|:----------:|
| SPI_SCLK | 10       | Header pin 10 | No Connection (Internal Clock is used) |
| SPI_MOSI | 11       | Header pin 11 | Slave MOSI |
| SPI_MISO | 12       | Header pin 12 | Slave MISO |
| SPI_CS_N | 9        | Header pin 9  | No Connection (No Slave) |
| GND      | 23       | GND           | GND on FPGA |  
  
### Loopback Test (No External Slave)  

* *Connect a jumper wire:
  Header pin 11 (SPI_MOSI) ──── Header pin 12 (SPI_MISO)*

* *This creates a hardware loopback:
  Whatever FPGA transmits on MOSI is received back on MISO, which confirms complete TX and RX signal path works*
    
### Build and Flash Commands
```bash
# From RTL directory:
sudo make clean
sudo make build
sudo make flash
sudo make terminal   # open serial monitor after flashing
```  
  
### UART Serial Moniter settings
| Parameter  | Value                  |
|:----------:|:----------------------:|
| Baud rate  | 9600                   |
| Data bits  | 8                      |
| Parity     | None                   |
| Stop bits  | 1                      |
| Port       | /dev/ttyUSB1 (CH340)   | 
  
> ***Note: If terminal shows nothing after flashing, press the RESET button
on the VSDSquadron board while the terminal is open to restart firmware***  

***