# *Commercial Grade SPI IP Documentation*
  
## ***1️⃣ IP Overview***  
  
### What Is This IP?  

*The SPI Master IP is a minimal, memory-mapped Serial Peripheral Interface (SPI) controller designed for the VSDSquadron FPGA platform. It allows the RISC-V CPU to communicate with external SPI slave devices by transmitting and receiving one byte at a time over a standard 4-wire SPI bus.*  
  
### Purpose
*SPI is one of the most widely used communication protocols in embedded systems. This IP enables the VSDSquadron RISC-V CPU to interface with a wide range of external devices - sensors, displays, flash memory, ADCs, DACs - that use the SPI protocol.*
  
### Typical Use Cases
 
* *Reading sensor data from SPI-based gyroscopes, accelerometers, or temperature sensors*
* *Writing to SPI flash memory or EEPROM*
* *Driving SPI-based displays or DACs*
* *Testing SPI slave devices during development*
* *Learning SPI protocol implementation from first principles*  
  
### When to Use This IP
*Use this IP when your application needs to communicate with any external device that uses SPI Mode 0 (CPOL=0, CPHA=0) and requires single-byte transfers. It is ideal for simple, low-to-medium speed communication where the CPU polls for completion rather than using interrupts.*  
  
***  
  
## ***2️⃣ Feature Summary***   

### Supported Features

* *SPI Mode 0 only (CPOL=0, CPHA=0)*
* *Single-byte (8-bit) transfer per transaction*
* *Configurable SCLK frequency via CLKDIV register field*
* *MSB-first bit ordering (industry standard)*
* *Hardware CS_N (Chip Select) generation, automatic assert/deassert*
* *Software-polled completion via BUSY and DONE status flags*
* *Write-1-to-clear DONE flag*
* *START bit auto-clears after triggering transfer*
* *New START ignored while transfer is in progress (BUSY=1)*
* *Memory-mapped 32-bit register interface*   
  
### Bit Widths

* *Data width: 8 bits per transfer*
* *Register width: 32 bits (bus width)*
* *CLKDIV field: 8 bits (bits [15:8] of CTRL)*

### Clock Assumptions

* *System clock: 12 MHz (VSDSquadron iCE40UP5K default)*
* *SCLK frequency: system_clk / (CLKDIV + 1)*
* *Minimum SCLK: 12MHz / 256 ≈ 46.9 KHz (CLKDIV=255)*
* *Maximum SCLK: 12MHz / 1 = 12 MHz (CLKDIV=0)*
* *Recommended: CLKDIV = 11 for 1 MHz (safe for most devices)*  
  
### Known Limitations

* *Single-byte transfers only — no burst or DMA support*
* *Mode 0 only, ie, ```CPOL = 1``` or ```CPHA = 1``` not supported*
* *Single slave only, one CS_N signal*
* *No interrupt support, software must poll STATUS*
* *No FIFO, CPU must read RXDATA before starting next transfer*
* *No multi-master support*
* *Assumes 12 MHz system clock for CLKDIV calculations*  
  
***  
  
## ***3️⃣ Block Diagram***  
  
<img width="694" height="1200" alt="Block_Diagram" src="https://github.com/user-attachments/assets/b6edcf2b-65e9-4f3c-8d4d-74c50eaf14b2" /> 
  
***  
  
## ***4️⃣ Register Map***    
  
* *Base Address: ```0x00400040```*
* *Bus Width: 32-bit, word-aligned*
* *Addressing: Base + offset*  
  
### Register Summary  
| Offset Address | Absolute Address | Name   | R/W | Description                           |
|:---:|:---:|:---:|:---:|:---:|
| 0x00          | 0x400040         | CTRL   | R/W | Control: enable, start, clock divider |
| 0x04          | 0x400044         | TXDATA | W   | Transmit data register                |
| 0x08          | 0x400048         | RXDATA | R   | Received data register                |
| 0x0C          | 0x40004C         | STATUS | R/W | Transfer status flags                 |  
  
### CTRL: Control Register (Offset 0x00)  
  
| Bits  | Field    | R/W | Reset | Description                                                     |
|:---:|:---:|:---:|:---:|:---:|
| 0      | EN       | R/W | 0     | Enable SPI block. Must be 1 before starting transfer          |
| 1      | START    | R/W | 0     | Write 1 to trigger transfer. Auto-clears internally. Ignored if BUSY=1 |
| 7:2    | Reserved |  - | 0     | -                                       |
| 15:8   | CLKDIV   | R/W | 0     | SCLK divider. SCLK = system_clk / (CLKDIV + 1)                |
| 31:16  | Reserved | -  | 0     | -                                       |  
  
### TXDATA: Transmit Data Register (Offset 0x04)    
  
* *Address: ```0x00400044```*
* *Access: Write-Only (reads return 0x00000000)*
* *Reset Value: ```0x00000000```*
  
| Bits | Field    | R/W | Reset | Description                                            |
|:---:|:---:|:---:|:---:|:---:|
| 7:0  | TXDATA   | W   | 0     | Byte to transmit. Loaded into shift register on START |
| 31:8 | Reserved | -   | 0     |-                      |  
  
> ***Note: Write TXDATA before asserting START. Writing during transfer has no effect on current transfer***  
  
### RXDATA: Received Data Register (Offset 0x08)  
  
* *Address: ```0x00400048```*
* *Access: Read-Only (writes are ignored)*
* *Reset Value: 0x00000000*  

| Bits | Field    | R/W | Reset | Description                                                  |
|:---:|:---:|:---:|:---:|:---:|
| 7:0  | RXDATA   | R   | 0     | Last byte received from slave via MISO. Updated at end of transfer. |
| 31:8 | Reserved | -   | 0     | Always reads 0                                              |  
  
> ***Note: RXDATA holds the received byte until the next completed transfer overwrites it. Read RXDATA only after DONE=1***
  
### STATUS: Status Register (Offset 0x0C)  
  
* *Address: ```0x0040004C```*
* *Access: Read/Write (only DONE bit is writable — write-1-to-clear)*
* *Reset Value: ```0x00000004```*  
  
| Bits | Field    | R/W  | Reset | Description                                                              |
|:-:|:-:|:-:|:-:|:-:|
| 0    | BUSY     | R    | 0     | 1 while transfer is in progress. 0 when idle                            |
| 1    | DONE     | R/W1C| 0     | Set to 1 when transfer completes. Stays 1 until cleared. Write 1 to clear |
| 2    | TX_READY | R    | 1     | 1 when IP is ready to accept new transfer (= NOT BUSY)                  |
| 31:3 | Reserved | -    | 0     | Always reads 0                                                          |  

*** 

## *5️⃣ Software Programming Model*  
  
### How Software Controls the IP
* *The SPI Master IP is entirely software-controlled through four memory-mapped registers. The CPU writes configuration, triggers transfers, polls status, and reads received data, all through normal memory load/store instructions*  
  
### Initialization Sequence  
```verilog
// Step 1: Configure clock divider and enable
// SCLK = 12MHz / (CLKDIV+1)  →  CLKDIV=11 gives 1MHz
SPI_CTRL = (11 << 8) | 1;    // CLKDIV=11, EN=1
```  
  
### Transfer Sequence  
```verilog  
// Step 2: Write data to transmit
SPI_TXDATA = 0xA5;

// Step 3: Trigger transfer (START auto-clears)
SPI_CTRL = (11 << 8) | 3;   // EN=1, START=1

// Step 4: Poll DONE flag (bit 1 of STATUS)
while (!(SPI_STATUS & (1 << 1)));

// Step 5: Read received byte
uint8_t received = (uint8_t)SPI_RXDATA;

// Step 6: Clear DONE flag (optional, for next transfer)
SPI_STATUS = (1 << 1);       // write-1-to-clear
```  
  
* *DONE flag is recommended because it confirms the transfer fully completed, not just that the state machine returned to IDLE*  

***  

## *6️⃣ Integration Guide*  
  
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

## *7️⃣ Board-level Usage*  

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

## *8️⃣ Example Software*    
  
### Register Address Definition
```C
#include <stdio.h>
#include <stdint.h>

// SPI Master IP — Base address and register definitions
#define SPI_BASE    0x400040

#define SPI_CTRL    (*((volatile uint32_t *)(SPI_BASE + 0x00)))
#define SPI_TXDATA  (*((volatile uint32_t *)(SPI_BASE + 0x04)))
#define SPI_RXDATA  (*((volatile uint32_t *)(SPI_BASE + 0x08)))
#define SPI_STATUS  (*((volatile uint32_t *)(SPI_BASE + 0x0C)))

// STATUS bit masks
#define SPI_BUSY      (1 << 0)
#define SPI_DONE      (1 << 1)
#define SPI_TX_READY  (1 << 2)

// CTRL bit masks
#define SPI_EN        (1 << 0)
#define SPI_START     (1 << 1)
```  
  
### Example: Basic single byte transfer  
* *Purpose: Validate SPI IP with MOSI shorted to MISO. Sends 0xA5 and verifies the same value is received back*
  
```C  
// Print 8 bits in binary format
void print_bin8(uint32_t val) {
    int i;
    for(i = 7; i >= 0; i--)
        printf("%d", (int)((val >> i) & 1));
}

int main() {
    printf("=== SPI Master Test Start ===\n");

    // Step 1: Configure — CLKDIV=11 gives 1MHz SPI clock
    // SCLK = 12MHz / (11+1) = 1MHz
    SPI_CTRL = (11 << 8) | SPI_EN;
    printf("CTRL configured: CLKDIV=11 EN=1\n");

    // Step 2: Write transmit data
    SPI_TXDATA = 0xA5;
    printf("TXDATA written : ");
    print_bin8(0xA5);
    printf(" (0xA5)\n");

    // Step 3: Start transfer
    SPI_CTRL = (11 << 8) | SPI_EN | SPI_START;
    printf("Transfer started\n");

    // Step 4: Poll DONE flag
    while(!(SPI_STATUS & SPI_DONE));
    printf("Transfer done!\n");

    // Step 5: Read received byte
    uint32_t received = SPI_RXDATA;
    printf("RXDATA received: ");
    print_bin8(received);
    printf(" (0x%X)\n", (unsigned int)received);

    // Step 6: Verify
    if(received == 0xA5)
        printf("RESULT: PASS - TX matches RX\n");
    else
        printf("RESULT: FAIL - mismatch!\n");

    // Step 7: Clear DONE flag
    SPI_STATUS = SPI_DONE;

    printf("=== SPI Master Test Done ===\n");
    return 0;
}
```  
  
### Expected Output on Terminal 
```bash
=== SPI Master Test Start ===
CTRL configured: CLKDIV=11 EN=1
TXDATA written : 10100101 (0xA5)
Transfer started
Transfer done!
RXDATA received: 10100101 (0xA5)
RESULT: PASS - TX matches RX
=== SPI Master Test Done ===
```  
  
### Compile and Run  
```bash
# From Firmware directory:
make spi_test.bram.hex   # compiles and copies to RTL/firmware.hex

# From RTL directory:
iverilog -DBENCH -o sim.vvp ice40_stubs.v riscv.v
vvp sim.vvp

# Hardware:
make build
sudo make flash
sudo make terminal
```  

***  

## *9️⃣ Validation and Expected Output*  
### What to Observe?
*When running spi_test.c on the VSDSquadron board with MOSI shorted to MISO
(loopback), the UART terminal should display:*
```bash
=== SPI Master Test Start ===
CTRL configured: CLKDIV=11 EN=1
TXDATA written : 10100101 (0xA5)
Transfer started
Transfer done!
RXDATA received: 10100101 (0xA5)
RESULT: PASS - TX matches RX
=== SPI Master Test Done ===
``` 
 
### Expected SPI Signal behaviour 
```bash
CS_N:  ‾‾‾‾|________________________________|‾‾‾‾
SCLK:   ____|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_|‾|_
MOSI:       [ 1   0   1   0   0   1   0   1 ]
MISO:     [ 1   0   1   0   0   1   0   1 ]
            ↑MSB                        ↑LSB
            <-----8 clock pulses total---->
```  
  
### Common Failure Symptoms
| Symptom                                | Likely Cause               | Fix                                             |
|:--------------------------------------:|:--------------------------:|:-----------------------------------------------:|
| Simulation hangs at "Transfer started" | DONE never set             | Check FINISH state logic                        |
| RXDATA = 0x00 always                   | MISO not connected         | Check loopback wire / MISO connection           |
| RXDATA wrong value                     | Bit order wrong            | Verify MSB-first, check shift direction         |
| Transfer never starts                  | EN = 0                     | Set EN = 1 in CTRL before START                 |
| Multiple transfers start automatically | START not auto-clearing    | Check auto-clear logic                          |
| UART shows nothing                     | Wrong ttyUSB port          | Change PICO_DEVICE in Makefile                  |  

***  

## *🔟 Known Limitations*  
* ***Single byte only:** Each transfer moves exactly 8 bits. Multi-byte transfers require multiple START sequences with polling between each*
* ***Mode 0 only:** CPOL=1 or CPHA=1 are not supported. Devices requiring other SPI modes are not compatible with this IP*
* ***No interrupt support:** Completion must be polled via STATUS register. The CPU is blocked during polling. Future versions may add interrupt output*
* ***Single chip select:** Only one CS_N signal is provided. Multiple slave devices would require external GPIO for additional CS lines*
* ***No FIFO:** There is no transmit or receive FIFO. The CPU must read RXDATA and write new TXDATA between every transfer*
* ***Clock assumption:** CLKDIV calculations assume a 12 MHz system clock. If system clock differs, recalculate CLKDIV accordingly*
* ***No loopback mode:** Hardware loopback requires a physical jumper wire between MOSI and MISO pins (pins 11 and 12 on VSDSquadron)*
* ***Simulation only ```ice40_stubs.v``` required:** The iCE40 primitive stubs file must be included before riscv.v in iverilog compilation*

***
