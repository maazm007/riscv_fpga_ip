## ***1️⃣ Register Map***    
  
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