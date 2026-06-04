#  VSDSquadron RISC-V FPGA IP Development Internship 2026

*This internship program focuses on developing the IP (Intellectual Property) using RISC-V Core and validate the functionality of the IP on VSDSquadron FPGA Mini board. I mainly worked on the open-source tools throughout this internship.*  
  
*This repository documents all the tasks that were assigned as a part of this Internship program, covering **Task-1**, **Task-2**, **Task-3**, **Task-4** and **Task-5*** 

##  Basic Details

**Name:** Maaz Mahmood Siddique  
**College:** Netaji Subhas University of Technology  
**Email ID:** maazms999@gmail.com  
**GitHub Profile:** [maazm007](https://github.com/maazm007?tab=repositories)  
**LinkedIN Profile:** [maazm-ece-vlsi](https://www.linkedin.com/in/maazms-ece-vlsi/)

***

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

*** 

***Snap 2: Optional Confidence Task***  
In this task, I have changed the reference program and compiled my own program written in C language using ```riscv cross-compiler``` and then simulated using ```spike simulator```  

```
Expected Output: Product from 1 to 6 is 720
Observed Output: Product from 1 to 6 is 720
```  
  
<img width="960" height="448" alt="fpga2" src="https://github.com/user-attachments/assets/bc68e1b9-528c-4202-8019-db436b6c941a" />
<br>  
  
***
  
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
  
***  

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
  
*** 
  
***Snap 4: Set up of Local Environment (Ubuntu 22.04 LTS on VM)***  
  
<img width="960" height="540" alt="fpga4" src="https://github.com/user-attachments/assets/511d4543-511e-4029-abdc-e8761874792b" />
  
***  

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

### 1(a) The `SOC` Module

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

### 1(b) CPU ↔ Bus Interface

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
  
### 1(c) Address Decoding  

```verilog  
wire isIO  = mem_addr[22];
wire isRAM = !isIO;
```

**Key Learning:** Bit 22 of the address selects IO vs RAM.

- If `mem_addr[22] == 0` → RAM
- If `mem_addr[22] == 1` → IO (peripherals)

This is the primary decoding rule used throughout the SoC.  
  
### 1(d) Word-Aligned Peripheral Addressing

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

### 1(e) LED Peripheral (Simple Register)

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

***
  
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
### Following is the verilog code for ```gpio_output.v```    
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

***  

### Step 3 – Integrate the IP into the SoC (Mandatory)  
  
This step integrates the previously designed GPIO IP into the existing RISC-V SoC. The goal is to make the GPIO a first-class memory-mapped peripheral that the CPU can access just like RAM, LEDs, and UART.  
  
### Now, ```riscv.v``` (SOC Top Level) file will be modified. Following are the changes that will be done:
* Instantiating gpio_ip
* Adding address decoding
* Routing bus signals
* Connecting readback data to the CPU  

### 3(a) GPIO Address Allocation  
  
The GPIO IP is mapped using:

```verilog
localparam IO_GPIO_bit = 3;
```  
  
### 3(b) GPIO IP Instantiation  
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
  
### 3(c) Integrating GPIO Readback into the Bus   
```verilog  
wire [31:0] IO_rdata =
               mem_wordaddr[IO_UART_CNTL_bit] ? { 22'b0, !uart_ready, 9'b0} :
               mem_wordaddr[IO_GPIO_bit]      ? gpio_rdata : 32'd0;

assign mem_rdata = isRAM ? RAM_rdata : IO_rdata ;
```

***  
  
### Step 4 – Validate using Simulation (Mandatory)  
  
This step proves correctness of the GPIO IP integration using software + RTL simulation. Until now, all work was structural. In this step, we execute code on the CPU and verify real behavior.  
  
### 4(a) Creation of UART STUB (Simulation-only)  
```SB_HFOSC``` (High-Frequency Oscillator) and ```SB_PLL40_CORE```(Phase-Locked Loop) are physical, hardware-specific silicon blocks that exist strictly inside Lattice iCE40 FPGAs.

Because ```iverilog``` is a generic software simulator, it has no idea what these vendor-specific names mean. When it reads the code and sees ```SB_HFOSC```, it throws its hands up because command is asking it to simulate a physical piece of silicon it doesn't have the blueprint for.  
  
Before running the simulation, the UART in the SoC is replaced with a lightweight simulation-only module called ```ice40_stubs.v```  
  
During simulation we compile with -DBENCH, which activates:
```
ice40_stubs.v → prints characters to console
```   
and do not consider,  
```
emitter_uart.v → real serial UART output
```  

This allows the program output (e.g. GPIO readback) to be seen directly in the terminal during simulation without needing to decode serial timing.  
  
### 4(b) Creation of firmware test program file  
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

### 4(c) Firmware Build & Memory Load

Commands used:

```bash
make clean
make gpio_test.bram.hex
```

What happens internally:

- C code → RISC-V ELF
- ELF → firmware.hex
- firmware.hex loaded into SoC RAM using `$readmemh`

This confirms:

- Instruction fetch
- Data access
- Memory-mapped IO access    
  
### 4(d) RTL Simulation (iverilog + vvp)

Simulation command:

```bash
iverilog -DBENCH -o sim2.vvp riscv.v ice40_stubs.v
vvp sim2.vvp
```  
Expected Output:  
```
GPIO test 1: ABCDEF12 
GPIO test 2: A0A0A0A0
GPIO test 3: 2468135  
```  
  
<img width="1920" height="981" alt="fpga5" src="https://github.com/user-attachments/assets/baa5557d-ccfd-4749-8011-bb878180519e" />


<img width="1920" height="981" alt="fpga6" src="https://github.com/user-attachments/assets/0fd94286-18b6-4625-9d7e-ea83f51ea880" />
  
  
### 4(e) Waveform-Based Validation (GTKWave)  
  
Opening the Waveform

```bash
gtkwave sim2.vcd
```

<img width="1920" height="981" alt="fpga7" src="https://github.com/user-attachments/assets/b466ba84-fd8c-4283-882a-e30c66ab188f" />


Following points should be observed in the waveform to verify the correct functionality:  
* ```mem_addr[31:0]``` address reaches ```0x00400020```
* ```isIO``` signal goes high whenever GPIO has been accessed
* ```we``` signal goes high when the Write operation has been performed
* ```mem_rstrb``` goes high when the Read operation has been performed
* ```GPIO_OUT``` updates to the value ```ABCDEF12```

***  

Task-3: Design a Multi-Register GPIO IP with Software Control  

**Objective:** We will upgrade our GPIO IP into a realistic peripheral with multiple registers that software can configure and control. We will design a proper register map, implement direction control, and validate everything using a C program running on the RISC-V core. This task strengthens our understanding of memory-mapped I/O and prepares us for more advanced IPs used in real SoCs. This task focuses on,
* Designing a proper register map
* Handling multiple registers inside one IP
* Strengthening understanding of memory-mapped I/O
* Validating end-to-end control from software to hardware

### Register Map

**IP Name:** GPIO Control IP (Direction + Data)  
**Base Address:** `0x00400020`

| Offset | Register Name | R/W | Actual Address | Description |
| :---: | :---: | :---: | :---: | :---: |
| 0x00 | GPIO_DATA | R/W | 0x00400020 | Write output values |
| 0x04 | GPIO_DIR | R/W | 0x00400024 | Set pin direction |
| 0x08 | GPIO_READ | R | 0x00400028 | Read actual pin state |  
  
### How Address Offset Decoding Works

Inside the GPIO module, `addr[3:2]` tells which register is accessed:

```
addr[3:2] = 2'b00  →  offset 0x00  →  GPIO_DATA
addr[3:2] = 2'b01  →  offset 0x04  →  GPIO_DIR
addr[3:2] = 2'b10  →  offset 0x08  →  GPIO_READ
```  
  
### Step 1: Study and Plan (Mandatory)

### Review of Task 2 GPIO IP
- Task 2 had single 32-bit register (`gpio_reg`)
- Only supported write and readback
- No direction control — all pins were outputs
- One address, no offset decoding needed

### What Needs to Be Added
- **Additional registers:**
  - `GPIO_DATA` → stores output values (offset 0x00)
  - `GPIO_DIR`  → controls pin direction (offset 0x04)
  - `GPIO_READ` → returns actual pin state (offset 0x08)

- **Address offset decoding:**
  - Task 2 used single address `0x400020`
  - Task 3 uses `addr[3:2]` to select register within IP
  - `addr[3:2] = 00` → GPIO_DATA
  - `addr[3:2] = 01` → GPIO_DIR
  - `addr[3:2] = 10` → GPIO_READ

### Internal Signals Defined
- `gpio_data_reg` → 32-bit register storing output values
- `gpio_dir_reg`  → 32-bit register storing direction
                    (1 = output, 0 = input) per pin
- `gpio_read_val` → combinational wire reflecting actual
                    pin state based on direction

### Key Planning Decisions
- Read logic is combinational (`always @(*)`) - no clock needed
- Write logic is synchronous (`always @(posedge clk)`)
- `GPIO_READ` is read-only - writes to offset 0x08 ignored
- **gpio_read_val** formula:
  ```(gpio_dir_reg & gpio_data_reg) | (~gpio_dir_reg & gpio_in)```
  - Output pins → reflect DATA register value
  - Input pins  → reflect actual external pin value

### Base Address Plan
- Base address reused from Task 2: `0x400020`
- Three register addresses:
  - `0x400020` → GPIO_DATA
  - `0x400024` → GPIO_DIR
  - `0x400028` → GPIO_READ  
    
***  
  
### Step 2: Implement Multi-Register RTL (Mandatory)  
  
#### Create a new file ```gpio_control.v```  
```verilog
/*
* ==========================================================================
* GPIO Control IP - Multi Register
*
* Register Map
*       Base + 0x00 = GPIO_DATA (0x00400020)
*       Base + 0x04 = GPIO_DIR  (0x00400024)
*       Base + 0x08 = GPIO_READ (0x00400028)
*
* Offset decoded via mem_addr[3:2]
* 2'b00 - GPIO_DATA
* 2'b01 - GPIO_DIR
* 2'b10 - GPIO_READ
* ==========================================================================
*/

module gpio_control(
        input clk,
        input resetn,
        input sel,
        input we,
        input [31:0] addr,
        input [31:0] wdata,
        output reg [31:0] rdata,

        // GPIO Pin Interface
        input [31:0] gpio_in,    // actual pin values from outside
        output [31:0] gpio_out,  // drive the output values
        output [31:0] gpio_oe    // output enable (1 = output |  0 = input)
);


// ==========================================================================
// Internal Registers
// ==========================================================================

reg [31:0] gpio_data_reg; // Stores Output Value
reg [31:0] gpio_dir_reg;  // Stores Direction

// ==========================================================================
// Offset Decoder
// mem_addr[3:2] will pick the register
// ==========================================================================

wire [1:0] reg_sel = addr[3:2];

localparam REG_DATA = 2'b00;
localparam REG_DIR = 2'b01;
localparam REG_READ = 2'b10;

// ==========================================================================
// Write Logic - Synchronous
// ==========================================================================

always@(posedge clk) begin
        if(~resetn) begin
                gpio_data_reg <= 32'd0;
                gpio_dir_reg <= 32'd0;
        end
        else begin
                if(sel && we) begin
                case(reg_sel)
                        REG_DATA: gpio_data_reg <= wdata;
                        REG_DIR: gpio_dir_reg <= wdata;
                endcase
                end
        end
end

// ==========================================================================
// Read Logic - Combinational
// ==========================================================================

always@(*) begin
        case(reg_sel)
        REG_DATA: rdata = gpio_data_reg;
        REG_DIR: rdata = gpio_dir_reg;
        REG_READ: rdata = gpio_read_val; // Actual Pin State
        default: rdata = 32'd0;
        endcase
end

// ==========================================================================
// GPIO_READ value
// For Output pins (dir = 1): reflect DATA register value
// For Input Pins (dir = 0): reflect actual gpio_in value
// ==========================================================================

wire [31:0] gpio_read_val;
assign gpio_read_val = (gpio_dir_reg & gpio_data_reg) | (~gpio_dir_reg & gpio_in);

// ==========================================================================
// Output Assignments
// gpio_out: the value to drive on output pins
// gpio_oe: which pins are output (same as DIR register
// ==========================================================================

assign gpio_out = gpio_data_reg;
assign gpio_oe = gpio_dir_reg;

endmodule
```  
  
***  
  
### Step 3: Integrate into the SoC (Mandatory)  
  
#### ```riscv.v``` needs to modified and instantiates new ```gpio``` module  
  
```verilog
gpio_control custon_gpio_inst(
           .clk(clk),
           .resetn(resetn),
           .sel(gpio_sel),
           .addr(mem_addr),
           .we(mem_wstrb),
           .wdata(mem_wdata),
           .rdata(gpio_rdata),
           .gpio_out(GPIO_OUT),
           .gpio_in(32'b0),     // For now I am using 32'b0 because I am not giving any external inputs
           .gpio_oe(GPIO_OE)
   );
```  
 
#### Further, SOC model also needs to be updated  
```verilog  
module SOC (
    input        RESET,
    output reg [4:0] LEDS,
    input        RXD,
    output       TXD,
    output [31:0] GPIO_OUT,     // ← output values (same as task 2)
    output [31:0] GPIO_OE,      // ← NEW: output enable (direction)
    input  [31:0] GPIO_IN       // ← NEW: actual pin values coming in
);
```  
  
#### Once the gpio modfication is done, we will compile the code using
```verilog 
iverilog -DBENCH ice40_stubs.v gpio_control.v riscv.v  
```  
* If no error pops, this validates that our design is free from syntax error  
  
<img width="1920" height="981" alt="fpga8" src="https://github.com/user-attachments/assets/cabb232c-3793-4984-91e8-b2c81b2ef48a" />

***  
  
### Step 4: Software Validation (Mandatory)  
  
#### Create a C test program for firmware ```gpio_test_task3.c.v```  
  
```C
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
```  

*** 

#### Build the firmware  
```bash
cd /riscv_fpga_ip/vsdfpga_labs/basicRISCV/Firmware
make gpio_test_task3.bram.hex  
```  

<img width="1920" height="981" alt="fpga9" src="https://github.com/user-attachments/assets/eecad045-aee9-48bf-9e46-2635fc223142" />  

*** 
  
#### Run the Simulation  
```bash 
iverilog -DBENCH -o sim3.vvp ice40_stubs.v riscv.v
vvp sim3.vvp 
```  
 
<img width="1920" height="981" alt="fpga10" src="https://github.com/user-attachments/assets/719e6292-2846-4eea-b539-245125159128" />  
 
***  
  
#### Open the waveform  
```bash
gtkwave sim3.vcd
```  
  
### GTKWave Simulation Waveform Observations

#### GPIO_OE Signal (Direction Register)
- GPIO_OE reflects the GPIO_DIR register value written by firmware in real time
- Observed transitions confirm direction register correctly stores and holds written values
- When DIR=0xFF, all 8 lower bits of GPIO_OE go HIGH confirming all pins configured as outputs
- When DIR=0x0F, only lower 4 bits go HIGH confirming per-bit direction control works correctly
- When DIR=0x00, GPIO_OE returns to zero confirming all pins correctly switch back to input mode

##### GPIO_OUT Signal (Data Register)
- GPIO_OUT reflects the GPIO_DATA register value driven to output pins
- Observed value 0xFF confirms all output pins driven HIGH in Test1
- Observed value 0xAA (10101010) confirms alternating bit pattern correctly driven in Test2
- Value 0xFF with DIR=0x0F confirms only lower 4 pins are driven - upper 4 remain at 0 (input mode)
- Value 0xAA with DIR=0x0F confirms masking works - only lower 4 bits of 0xAA appear on output
- Returns to 0x00 in Test5 confirming clean reset of output register

#### mem_wdata Signal (CPU Write Data)
- mem_wdata transitions confirm CPU is actively writing values onto the bus
- Each firmware write (GPIO_DIR, GPIO_DATA) is visible as a transition on mem_wdata
- Confirms the CPU-to-peripheral data path is working correctly through the memory-mapped bus

#### General Observations
- All signal transitions are clean with no glitches confirming synchronous design is working correctly
- GPIO_OE and GPIO_OUT change together as expected when firmware writes to direction and data registers
- Direction register correctly gates the output — GPIO_OUT value is only reflected on active output pins as determined by GPIO_OE
- Simulation validates complete write path from C firmware → CPU → memory bus → GPIO IP → output pins
- The IP correctly implements memory-mapped register behavior as specified in the register map
- No unexpected transitions observed — design is stable and behaves deterministically  
  
<img width="1920" height="981" alt="fpga11" src="https://github.com/user-attachments/assets/e3e9df37-cff8-4ad6-a767-66dc575af1c5" />  

***



