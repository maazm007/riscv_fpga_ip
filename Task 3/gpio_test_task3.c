#include <stdio.h>
#include <stdint.h>

// GPIO register addresses
#define GPIO_BASE  0x00400020
#define GPIO_DATA  (*((volatile uint32_t *)(GPIO_BASE + 0x00)))
#define GPIO_DIR   (*((volatile uint32_t *)(GPIO_BASE + 0x04)))
#define GPIO_READ  (*((volatile uint32_t *)(GPIO_BASE + 0x08)))

// Print 8 bits in binary (we use 8 bits for GPIO)
void print_bin8(uint32_t val) {
    int i;
    for(i = 7; i >= 0; i--) {
        printf("%d", (int)((val >> i) & 1));
    }
}

int main() {
    printf("+++ GPIO Task 3 Test Start +++\n");
    printf("Format: DIR=xxxxxxxx DATA=xxxxxxxx READ=xxxxxxxx\n\n");

    // Test 1: All pins output, write 0xFF
    GPIO_DIR  = 0xFF;
    GPIO_DATA = 0xFF;
    printf("Test1: DIR="); print_bin8(0xFF);
    printf(" DATA=");      print_bin8(0xFF);
    printf(" READ=");      print_bin8(GPIO_READ);
    printf(" (expect 11111111)\n");

    // Test 2: All pins output, write 0xAA
    GPIO_DIR  = 0xFF;
    GPIO_DATA = 0xAA;
    printf("Test2: DIR="); print_bin8(0xFF);
    printf(" DATA=");      print_bin8(0xAA);
    printf(" READ=");      print_bin8(GPIO_READ);
    printf(" (expect 10101010)\n");

    // Test 3: Lower 4 pins output, write 0xFF
    GPIO_DIR  = 0x0F;
    GPIO_DATA = 0xFF;
    printf("Test3: DIR="); print_bin8(0x0F);
    printf(" DATA=");      print_bin8(0xFF);
    printf(" READ=");      print_bin8(GPIO_READ);
    printf(" (expect 00001111)\n");

    // Test 4: Lower 4 pins output, write 0xAA
    GPIO_DIR  = 0x0F;
    GPIO_DATA = 0xAA;
    printf("Test4: DIR="); print_bin8(0x0F);
    printf(" DATA=");      print_bin8(0xAA);
    printf(" READ=");      print_bin8(GPIO_READ);
    printf(" (expect 00001010)\n");

    // Test 5: Clear everything
    GPIO_DIR  = 0x00;
    GPIO_DATA = 0x00;
    printf("Test5: DIR="); print_bin8(0x00);
    printf(" DATA=");      print_bin8(0x00);
    printf(" READ=");      print_bin8(GPIO_READ);
    printf(" (expect 00000000)\n");

    printf("\n+++ GPIO Task 3 Test Done +++\n");
    return 0;
}
