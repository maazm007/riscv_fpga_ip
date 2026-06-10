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
  

  
***  
  
## ***4️⃣ Software Programming Model***  
  
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
  
## ***5️⃣ Validation and Expected Output***  
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

## ***6️⃣ Known Limitations***  
* ***Single byte only:** Each transfer moves exactly 8 bits. Multi-byte transfers require multiple START sequences with polling between each*
* ***Mode 0 only:** CPOL=1 or CPHA=1 are not supported. Devices requiring other SPI modes are not compatible with this IP*
* ***No interrupt support:** Completion must be polled via STATUS register. The CPU is blocked during polling. Future versions may add interrupt output*
* ***Single chip select:** Only one CS_N signal is provided. Multiple slave devices would require external GPIO for additional CS lines*
* ***No FIFO:** There is no transmit or receive FIFO. The CPU must read RXDATA and write new TXDATA between every transfer*
* ***Clock assumption:** CLKDIV calculations assume a 12 MHz system clock. If system clock differs, recalculate CLKDIV accordingly*
* ***No loopback mode:** Hardware loopback requires a physical jumper wire between MOSI and MISO pins (pins 11 and 12 on VSDSquadron)*
* ***Simulation only ```ice40_stubs.v``` required:** The iCE40 primitive stubs file must be included before riscv.v in iverilog compilation*  
  
***