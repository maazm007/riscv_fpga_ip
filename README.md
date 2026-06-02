#  VSDSquadron RISC-V FPGA IP Development Internship 2026

*This internship program focuses on developing the IP (Intellectual Property) using RISC-V Core and validate the functionality of the IP on VSDSquadron FPGA Mini board. I mainly worked on the open-source tools throughout this internship.*  
  
*This repository documents all the tasks that were assigned as a part of this Internship program, covering **Task-1**, **Task-2**, **Task-3**, **Task-4** and **Task-5*** 

##  Basic Details

**Name:** Maaz Mahmood Siddique  
**College:** Netaji Subhas University of Technology  
**Email ID:** maazms999@gmail.com  
**GitHub Profile:** [maazm007](https://github.com/maazm007?tab=repositories)  
**LinkedIN Profile:** [maazm-ece-vlsi](https://www.linkedin.com/in/maazms-ece-vlsi/)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Task-1: Environment Setup & RISC-V Reference Bring-Up  
  
**Objective:** Set up the development environment and successfully run a working RISC-V reference design, followed by running the VSDFPGA labs on the same environment. This task focuses on:  
* Toolchain readiness  
* Understanding the RISC-V execution flow
* Preparing for upcoming FPGA and IP development work
  
### **Following are the snapshots required for submission**  
  
***Snap 1: Compilation of referebce RISC-V program***  

```
Expected Output: Sum from 1 to 9 is 45
Observed Output: Sum from 1 to 9 is 45
``` 
  
<img width="960" height="451" alt="fpga1" src="https://github.com/user-attachments/assets/d39da0ae-2e42-4765-b097-6ea6ce49bece" />

----------------------------------------- 

***Snap 2: Optional Confidence Task***  
In this task, I have changed the reference program and compiled my own program written in C language using ```riscv cross-compiler``` and then simulated using ```spike simulator```  

```
Expected Output: Product from 1 to 6 is 720
Observed Output: Product from 1 to 6 is 720
```  
  
<img width="960" height="448" alt="fpga2" src="https://github.com/user-attachments/assets/bc68e1b9-528c-4202-8019-db436b6c941a" />
<br>  
  
------------------------------------------------------------------
  
***Snap 3: VSD FPGA Firmware Build (No Hardware Required)***    
* Firstly, the ```riscv_logo.c``` has been created and then **hex** has to be generated using the command ```make riscv_logo.bram.hex```
* Then the generated hex file is compiled using ```riscv cross-compiler``` and simulated using ```spike simulator```
* Upon simulation, following output should be observed,  
```
********************************
*LEARN TO THINK LIKE A CHIP    *
*VSDSQUADRON FPGA MINI         *
*BRINGS RISC-V TO VSD CLASSROOM*
********************************
```  
  
<img width="960" height="449" alt="fpga3" src="https://github.com/user-attachments/assets/9854a322-3df8-465c-be1d-ef6842cb5b5a" />
  
--------------------------------------------------- 
***Understanding Check Questions***  
<br>
**Ques 1:** Where is RISC-V program located?  
***Answer:** The RISC-V reference program is located in the ```samples``` directory of the ```vsd-riscv2``` repository.*  
<br>
**Ques 2:** How is the program compiled and loaded into memory?  
***Answer:** The source code is cross-compiled into a statically linked Executable and Linkable Format (ELF) binary targeting the 64-bit RISC-V architecture via the ```riscv64-unknown-elf-gcc``` toolchain. Execution is handled by Spike, the official RISC-V ISA simulator, operating in tandem with the RISC-V Proxy Kernel (pk). The proxy kernel acts as a lightweight runtime manager; it parses the ELF program headers, maps the executable segments into simulated physical memory, initializes the architectural state, and proxies system calls from the simulated hardware thread (hart) to the host operating system.*
<br>  
**Ques 3:**  How does the RISC-V core access memory and memory-mapped IO?  
***Answer:** The RISC-V core accesses memory and peripherals using standard load and store instructions. Memory-mapped IO allows peripherals to be accessed via specific address ranges.*   
<br>
**Ques 4:**  Where would a new FPGA IP block logically integrate?  
***Answer:** A new FPGA IP block would integrate as a memory-mapped peripheral connected to the SoC interconnect, allowing communication with the RISC-V core through standard load/store operations.*  
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
  
***Snap 4: Set up of Local Environment (Ubuntu 22.04 LTS on VM)***  
  
<img width="960" height="540" alt="fpga4" src="https://github.com/user-attachments/assets/511d4543-511e-4029-abdc-e8761874792b" />
  
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------  

Task-2: Design & Integrate Your First Memory-Mapped IP  

**Objective:** Design a simple memory-mapped IP, integrate it into the existing RISC-V SoC, and validate it through simulation. Following are the specifications of IP:
* One 32-bits register 
* Writing to the register updates an output signal
* Reading the register returns the last written value  
* Memory-mapped interface, connected to the existing CPU bus  
* Uses the same bus signals already present in the SoC  

**The relevant files which will be used in this task are as follows:**  
```
basicRISCV/
├── RTL/
│   ├── riscv.v                 ← Top-level SoC + CPU + Memory
│   ├── ice40_stubs.v           ← UART transmitter peripheral
│   └── gpio_output.v           ← For Task 2 (1 register GPIO)
│
├── Firmware/
│   ├── gpio_test.c             ← C test programs
│   ├── firmware.hex            ← Linker script
│   └── Makefile
```  
  
### Step-1: Understanding the SoC Top-Level (`riscv.v`)

#### 1. The `SOC` Module

The `SOC` module is the **top-level integration point**. It connects:

- CPU
- RAM
- UART
- LED logic
- Clock and reset

This is where **all peripherals are wired together**.

Key signals exposed in the SoC:

```verilog
wire [31:0] mem_addr;
wire [31:0] mem_rdata;
wire        mem_rstrb;
wire [31:0] mem_wdata;
wire [3:0]  mem_wmask;
```

These signals form the CPU bus interface.

#### 2. CPU ↔ Bus Interface

Inside `riscv.v`, the CPU is instantiated as:

```verilog
Processor CPU (
    .clk        (clk),
    .resetn     (resetn),
    .mem_addr   (mem_addr),
    .mem_rdata  (mem_rdata),
    .mem_rstrb  (mem_rstrb),
    .mem_wdata  (mem_wdata),
    .mem_wmask  (mem_wmask)
);
```

From this, we learn the CPU does not know about peripherals. It only:

- Places an address on `mem_addr`
- Asserts read (`mem_rstrb`) or write (`mem_wmask`)
- Receives data via `mem_rdata`

All peripheral logic must respond to these signals.  
  
#### 3. Address Decoding  

```verilog  
wire isIO  = mem_addr[22];
wire isRAM = !isIO;
```

**Key Learning:** Bit 22 of the address selects IO vs RAM.

- If `mem_addr[22] == 0` → RAM
- If `mem_addr[22] == 1` → IO (peripherals)

This is the primary decoding rule used throughout the SoC.  
  
#### 4. Word-Aligned Peripheral Addressing

The SoC uses word-aligned addressing:

```verilog
wire [29:0] mem_wordaddr = mem_addr[31:2];
```

Peripherals are selected using 1-hot bits of `mem_wordaddr`.

Defined IO layout:

```verilog
localparam IO_LEDS_bit      = 0;
localparam IO_UART_DAT_bit  = 1;
localparam IO_UART_CNTL_bit = 2;
```  
  
| Peripheral | Word Address Bit | Purpose            |
|------------|------------------|--------------------|
| LED        | bit 0            | Write LED register |
| UART TX    | bit 1            | Write UART data    |
| UART ST    | bit 2            | Read UART status   |

#### 5. LED Peripheral (Simple Register)

LED logic is implemented directly in SOC:

```verilog
always @(posedge clk) begin
    if (!resetn)
        LEDS <= 5'b0;
    else if (isIO & mem_wstrb & mem_wordaddr[IO_LEDS_bit])
        LEDS <= mem_wdata[4:0];
end
```

Key observations:

- LEDs are memory-mapped
- Written using `mem_wdata`
- Enabled by `isIO`, `mem_wstrb`, and address decode

This serves as a reference model for writing a GPIO peripheral.  
  
### Step 2 – Write the GPIO IP RTL (Mandatory)  
  
This step focuses on **designing a standalone, correct GPIO IP block** that follows the **existing SoC bus protocol** discovered in Step 1.

At this stage:
- The GPIO IP is **not yet connected to the SoC**
- The goal is **correct RTL behavior**, not optimization
- The IP must be **bus-compliant and synthesizable**  

*Now we need to create a RTL file named as ```gpio_output.v```*
  
The GPIO IP exposes the following interface:    
```verilog
input             clk,
input             resetn,
input             gpio_sel,    // High when CPU is using this IP
input             gpio_we,     // Write Enable
input      [31:0] gpio_wdata,  // Data written by CPU
output reg [31:0] gpio_rdata,  // Data read by CPU
output     [31:0] gpio_out;    // Connection to outer ports
reg        [31:0] gpio_reg;    // Internal Register
```  
#### Following is the verilog code for ```gpio_output.v```    
```verilog
/*
* Simple GPIO Output IP (Write-Only with readback)
* Memory-mapped register at IO_GPIO_bit = 3
* Address is 0x00400020
*/

module gpio_output(
       input clk,
       input resetn,
       input gpio_sel, // High when CPU is using this IP
       input gpio_we, // Write Enable
       input [31:0] gpio_wdata, // Data written by CPU
       output reg [31:0] gpio_rdata, // Data read by CPU

      // External Hardware Output

       output [31:0] gpio_out); // Connection to outer ports

       reg [31:0] gpio_reg; // Latching the value      

       // Write Logic
       always@(posedge clk) begin
          if(~resetn)
             gpio_reg <= 32'd0;
          else begin
             if(gpio_sel && gpio_we)
                gpio_reg <= gpio_wdata;
          end
       end

       // Readback Logic
       // When CPU read this IP, return the last value stored in the register
       // Otherwise, drive the read bus to 0
       always@(*) begin
          if(gpio_sel)
             gpio_rdata <= gpio_reg;
          else
             gpio_rdata <= 32'd0;
       end

       // Drive External Logic
       assign gpio_out = gpio_reg;
endmodule
```  
  
### Step 3 – Integrate the IP into the SoC (Mandatory)  
  
This step integrates the previously designed GPIO IP into the existing RISC-V SoC. The goal is to make the GPIO a first-class memory-mapped peripheral that the CPU can access just like RAM, LEDs, and UART.  
  
#### Now, ```riscv.v``` (SOC Top Level) file will be modified. Following are the changes that will be done:
* Instantiating gpio_ip
* Adding address decoding
* Routing bus signals
* Connecting readback data to the CPU  

#### GPIO Address Allocation  
  
The GPIO IP is mapped using:

```verilog
localparam IO_GPIO_bit = 3;
```  
  
#### GPIO IP Instantiation  
```verilog
wire [31:0] gpio_rdata;

gpio_output custon_gpio_inst(
        .clk(clk),
        .resetn(resetn),
        .gpio_sel(gpio_sel),
        .gpio_we(mem_wstrb),
        .gpio_wdata(mem_wdata),
        .gpio_rdata(gpio_rdata),
        .gpio_out(GPIO_OUT)
   );
```  
  
#### Integrating GPIO Readback into the Bus   
```verilog  
wire [31:0] IO_rdata =
               mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0} :
               mem_wordaddr[IO_GPIO_bit]      ? gpio_rdata : 32'd0;

assign mem_rdata = isRAM ? RAM_rdata : IO_rdata ;
```  
  
### Step 4 – Validate using Simulation (Mandatory)  
  
This step proves correctness of the GPIO IP integration using software + RTL simulation. Until now, all work was structural. In this step, we execute code on the CPU and verify real behavior.  
  
#### Creation of UART STUB (Simulation-only)  
```SB_HFOSC``` (High-Frequency Oscillator) and ```SB_PLL40_CORE```(Phase-Locked Loop) are physical, hardware-specific silicon blocks that exist strictly inside Lattice iCE40 FPGAs.

Because ```iverilog``` is a generic software simulator, it has no idea what these vendor-specific names mean. When it reads the code and sees ```SB_HFOSC```, it throws its hands up because command is asking it to simulate a physical piece of silicon it doesn't have the blueprint for.  
  
Before running the simulation, the UART in the SoC is replaced with a lightweight simulation-only module called ```ice40_stubs.v```  
  
During simulation we compile with -DBENCH, which activates:
```
uart_stub.v → prints characters to console
```   
and do not consider,  
```
emitter_uart.v → real serial UART output
```  

This allows the program output (e.g. GPIO readback) to be seen directly in the terminal during simulation without needing to decode serial timing.  
  
#### Creation of firmware test program file  
This C program runs on the RISC-V CPU and interacts with GPIO  
```C
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
```

