## ***1️⃣ Example Software***    
  
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