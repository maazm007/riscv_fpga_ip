# ***Commercial Grade SPI IP Documentation***
  
## ***SPI Master IP - VSDSquadron FPGA***
* *A minimal, memory-mapped SPI Master IP for the **VSDSquadron FPGA (Lattice iCE40UP5K)***
* *Transmits and receives 8-bit data in Mode 0 (CPOL=0, CPHA=0) over a standard 4-wire SPI interface. Designed for plug-and-play integration into the VSDSquadron RISC-V SoC*  
  
***  
  
## ***What This IP Does***

* *Transmits and receives one byte (8 bits) over SPI at a configurable clock rate*
* *Software-controlled via 4 memory-mapped registers*
* *Generates SCLK, MOSI, CS_N and samples MISO automatically*
* *Reports transfer status (BUSY, DONE) to firmware*  
  
***  
  
## ***Quick Integration (3 Steps)***  
  
### ***Step 1: Copy RTL file*** 
```bash
RTL/spi_master.v
```  
  
### ***Step 2: Instantiate SoC***  
```bash
spi_master spi_ip(
    .clk(clk), 
    .resetn(resetn),
    .sel(spi_sel), 
    .we(mem_wstrb),
    .addr(mem_addr), 
    .wdata(mem_wdata),
    .rdata(SPI_rdata),
    .SCLK(SPI_SCLK), 
    .MOSI(SPI_MOSI),
    .MISO(SPI_MISO), 
    .CS_N(SPI_CS_N)
);
```  
  
### ***Step 3: Add Address Decode***  
```bash
localparam IO_SPI_bit = 4;
wire spi_sel = isIO & mem_wordaddr[IO_SPI_bit];
// Base address: 0x400040
```  
  
***  
  
## ***How to Test?***  
```bash
SPI_CTRL  = (11 << 8) | 1;          // CLKDIV=11, EN=1
SPI_TXDATA = 0xA5;
SPI_CTRL  = (11 << 8) | 3;          // START=1
while(!(SPI_STATUS & (1<<1)));
printf("RX: 0x%X\n", SPI_RXDATA);   // expect 0xA5
```  
  
***  
  
## ***Where to find Documents?***   
| Document | Location |
| :---: | :---: |
| Full User Guide | [IP_SPI/DOCS/Full_User_Guide.md](https://github.com/maazm007/riscv_fpga_ip/blob/main/IP_SPI/DOCS/Full_User_Guide.md) |
| Integration Guide | [IP_SPI/DOCS/Integration_Guide.md](https://github.com/maazm007/riscv_fpga_ip/blob/main/IP_SPI/DOCS/Integration_Guide.md) |
| Register Map | [IP_SPI/DOCS/Register_Map.md](https://github.com/maazm007/riscv_fpga_ip/blob/main/IP_SPI/DOCS/Register_Map.md) |
| Example Software | [IP_SPI/DOCS/Example_Software.md](https://github.com/maazm007/riscv_fpga_ip/blob/main/IP_SPI/DOCS/Example_Software.md) |
| Firmware Source | [IP_SPI/SOFTWARE/spi_test.c](https://github.com/maazm007/riscv_fpga_ip/blob/main/IP_SPI/SOFTWARE/spi_test.c) |
| RTL Source | [IP_SPI/RTL](https://github.com/maazm007/riscv_fpga_ip/tree/main/IP_SPI/RTL) |  
  
***
