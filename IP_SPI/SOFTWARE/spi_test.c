#include <stdio.h>
#include <stdint.h>

// SPI register addresses
#define SPI_BASE   0x400040
#define SPI_CTRL   (*((volatile uint32_t *)(SPI_BASE + 0x00)))
#define SPI_TXDATA (*((volatile uint32_t *)(SPI_BASE + 0x04)))
#define SPI_RXDATA (*((volatile uint32_t *)(SPI_BASE + 0x08)))
#define SPI_STATUS (*((volatile uint32_t *)(SPI_BASE + 0x0C)))

// Print 8 bits in binary
void print_bin8(uint32_t val) {
    int i;
    for(i = 7; i >= 0; i--)
        printf("%d", (int)((val >> i) & 1));
}

int main() {
    printf("\n=== SPI Master Test Start ===\n");

    // Step 1: Configure CLKDIV=11, EN=1
    // SCLK = 12MHz / (11+1) = 1MHz
    SPI_CTRL = (11 << 8) | 1;
    printf("CTRL configured: CLKDIV=11 EN=1\n");

    // Step 2: Write TXDATA = 0xA5
    SPI_TXDATA = 0xA5;
    printf("TXDATA written : ");
    print_bin8(0xA5);
    printf(" (0xA5)\n");

    // Step 3: Start transfer (write START=1)
    SPI_CTRL = (11 << 8) | 3;   // EN=1, START=1
    printf("Transfer started\n");

    // Step 4: Poll DONE flag (bit 1 of STATUS)
    while(!(SPI_STATUS & (1 << 1)));
    printf("Transfer done!\n");

    // Step 5: Read RXDATA and verify
    uint32_t received = SPI_RXDATA;
    printf("RXDATA received: ");
    print_bin8(received);
    printf(" (0x%x)\n", (unsigned int)received);

    // Step 6: Verify
    if(received == 0xA5)
        printf("RESULT: PASS - TX matches RX\n");
    else
        printf("RESULT: FAIL - mismatch!\n");

    printf("\n=== SPI Master Test Done ===\n");
    return 0;
}
