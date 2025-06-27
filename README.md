# SOC2025_MiniGPU


##  1. Digital Circuit Basics

I started with the foundations: **Boolean algebra**, **logic gates**, and **combinational circuits**. Learned how things like **MUX**, **decoders**, **encoders**, and **tristate buffers** work. Figured out how NAND/NOR logic can be composed from simpler gates and how timing, propagation, and memoryless vs memory-based logic matter.

This set the stage — because without knowing how electrons follow logic, you can’t really design anything.

---

##  2. Verilog Guide

- Explored the **behavioral vs structural** modeling styles  
- Understood the difference between `wire` and `reg`  
- Learned how synthesis works and how testbenches simulate behavior  
- Got into **FSMs**, modules, port declarations, and how `assign`, `always`, `case`, `if` are used


---

##  3. ISA (Instruction Set Architecture)

Got introduced to **MicroMIPS**, a simplified ISA. Learned how instructions like `add`, `lw`, `beq`, `jal` work and how they're structured (R, I, and J formats).  
Saw how a CPU reads instructions, fetches operands from registers, performs ALU ops, and writes back.

This was the bridge between **software instruction-level execution** and **hardware implementation**.

---

##  4. Datapath

Dived into how data flows through a CPU. Understood components like:
- **ALU**
- **Register file**
- **PC (program counter)**
- **MUXes**, **control lines**, and memory units


---

##  5. ALU + Register File

Wrote the Verilog for an 8-bit ALU that supports `add`, `sub`, `and`, `xor`, `mul`, `div`. Learned how to set flags like **NZP** based on result signs.

Also learned about the **Register File**: a bank of 16 registers with dual read + single write support. Figured out how `reg_input_mux` and `core_state` control read/write phases. Learned how to integrate ALU outputs into the register file through controlled write logic.

---

##  6. Threads

Finally, I got into **GPU-style threading**. Understood how **thread datapaths** replicate this ALU-RF-PC-NZP architecture per thread.  
Saw how **thread ID**, **block ID**, and control signals synchronize multiple threads per block. Learned how **immediate values**, **branching with NZP**, and **LSU read/write** control thread execution.

The threading model brings it all together — it's like building a simplified multi-core processor.

---

##  7. Quartus Prime — FPGA Synthesis & Implementation

Started using **Quartus Prime** to synthesize and implement Verilog designs on FPGAs.  
Learned how to:
- Compile a design
- Use **RTL Viewer** and **Technology Map Viewer**

This tool bridges the gap between **Verilog code** and **actual logic blocks** on silicon.

---

## 8. ModelSim — Simulation & Debugging

Used **ModelSim** to simulate Verilog testbenches.  
Learned how to:
- Write testbenches to verify ALU, register file, and thread logic
- Use `$display`, `$monitor`, and waveforms to trace execution
- Handle `vlib`, `vlog`, `vsim`, and `run -all` commands


---

## 9. FPGA Flow — End to End

From logic design to hardware:
1. **Write Verilog**
2. **Simulate in ModelSim**
3. **Synthesize in Quartus**
4. **Assign pins**
5. **Program FPGA**
6. **Watch it run on real hardware**


---

