#include <stdio.h>
#include <stdint.h>

#define GPIO_ADDR 0x00400020
volatile uint32_t *gpio = (volatile uint32_t *)GPIO_ADDR;

void main() {
    *gpio = 0xABCDEF12;
    printf("GPIO test 1: %x\n", (unsigned int)*gpio);

    *gpio = 0xA0A0A0A0;
    printf("GPIO test 2: %x\n", (unsigned int)*gpio);

    *gpio = 0x02468135;
    printf("GPIO test 3: %x\n", (unsigned int)*gpio);

    printf("ALL TESTS DONE\n");
}
