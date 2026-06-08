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
