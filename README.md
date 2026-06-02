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
  
<img width="960" height="451" alt="fpga1" src="https://github.com/user-attachments/assets/d39da0ae-2e42-4765-b097-6ea6ce49bece" />
<br>  

```
Expected Output: Sum from 1 to 9 is 45
Observed Output: Sum from 1 to 9 is 45
```   

----------------------------------------- 

***Snap 2: Optional Confidence Task***  
In this task, I have changed the reference program and compiled my own program written in C language using ```riscv cross-compiler``` and then simulated using ```spike simulator```  
  
<img width="960" height="448" alt="fpga2" src="https://github.com/user-attachments/assets/bc68e1b9-528c-4202-8019-db436b6c941a" />
<br>  

```
Expected Output: Product from 1 to 6 is 720
Observed Output: Product from 1 to 6 is 720
```  
  
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
  
--------------------------------------------------------  
  
***Snap 4: Set up of Local Environment (Ubuntu 22.04 LTS on VM)***  
  
<img width="960" height="540" alt="fpga4" src="https://github.com/user-attachments/assets/511d4543-511e-4029-abdc-e8761874792b" />
  
---------------------------------------------------------------

