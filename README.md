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

## Post Midterm
**GPU Folder contains all the required source files(modules) and testbenches, also file named Screenshots contains important screenshots**

## What I Learned

Based on the project's design, I gained experience with the following advanced digital design concepts:

* **Single Instruction, Multiple Threads (SIMT) Architecture:** The `miniGPU_core` module implements a simplified SIMT architecture by broadcasting a single instruction from the decoder to multiple thread datapaths. Each thread executes the same instruction concurrently but operates on its own local data stored in its dedicated register file.
* **Hierarchical State Machines:** The project uses a multi-level state machine approach. The `core_fsm` orchestrates the overall instruction pipeline (Fetch, Decode, Execute) for a core. Nested within this are smaller FSMs in the `fetcher` and `lsu` modules, which handle the specific, multi-cycle tasks of instruction fetching and memory access. The `core_fsm` pauses to check the states of these sub-FSMs before managing its own transitions.
* **Workload Dispatching and Task Management:** The `dispatch` module demonstrates how to manage a parallel workload by dividing a total `thread_count` into smaller blocks. It dynamically assigns these blocks to available compute cores, ensuring that all work is completed efficiently.
* **Configurable and Scalable Hardware Design:** The use of `parameter` declarations in `dispatch.v` and `gpu.v` allows for the number of cores and threads per block to be easily changed without modifying the core logic. The `generate` and `genvar` constructs in `gpu.v` provide a powerful way to instantiate and connect multiple identical modules, enabling a highly scalable design.
* **Memory Controllers and Arbitration:** The `controller` modules act as arbiters, managing the interface between multiple consumers (fetchers and LSUs) and the shared memory resources (program and data memory). This is a fundamental concept in building complex systems where multiple components need to share access to a single resource.

---

## The Flow

This project represents a complete flow from high-level control to low-level execution. The flow of a program from start to finish is as follows:

1.  **Configuration and Initialization:**
    * [cite_start]A host system writes a value to the Device Control Register (`dcr.v`) via `device_control_write_enable` and `device_control_data`, which sets the total `thread_count` for the GPU to execute[cite: 1, 2, 84].
    * [cite_start]The `dispatch` module receives this `thread_count` and, upon a `start` signal, begins dividing the workload into blocks to be executed by the cores[cite: 6, 8]. [cite_start]It keeps track of how many blocks have been processed[cite: 9].

2.  **Dispatch and Core Activation:**
    * [cite_start]The `dispatch` module identifies an available core and assigns it a block by asserting `core_start`[cite: 17, 23]. [cite_start]It also provides the core with a `core_block_id` and the number of threads in that block (`core_thread_count`)[cite: 18, 19, 24, 25].

3.  **Instruction Pipeline within a Core:**
    * [cite_start]Each `miniGPU_core` starts its `core_fsm` in the `IDLE` state[cite: 112, 118]. [cite_start]Upon receiving `start`, the FSM transitions to `FETCH`[cite: 120].
    * [cite_start]The `fetcher` module requests the next instruction from the `program_memory_controller` at the address specified by the Program Counter (`current_pc`)[cite: 107, 108, 111, 163].
    * [cite_start]Once the instruction is received, the FSM moves to `DECODE`[cite: 109, 121]. [cite_start]The `decoder` module decodes the instruction and generates the necessary control signals[cite: 29, 36, 164].
    * [cite_start]The core FSM transitions to `REQUEST` and then either `WAIT` (for memory operations) or `EXECUTE` (for ALU operations)[cite: 122, 123, 124].
    * [cite_start]If a memory operation is required, the `lsu` modules for all threads initiate a request to the `data_memory_controller`[cite: 124, 189, 195]. [cite_start]The `core_fsm` pauses in the `WAIT` state until the `lsu` modules signal that the operation is complete[cite: 124, 129, 193, 198].
    * [cite_start]After execution, the `core_fsm` updates the `current_pc` and loops back to the `FETCH` state to process the next instruction[cite: 130, 132].

4.  **Task Completion:**
    * [cite_start]When a core decodes a `RET_OPCODE` instruction [cite: 34][cite_start], the `decoded_ret` signal is asserted[cite: 57]. [cite_start]The `core_fsm` recognizes this and transitions to a `DONE_STATE`[cite: 131].
    * [cite_start]The `dispatch` module registers that the core is done via the `core_done` signal [cite: 22, 28, 88] [cite_start]and, if more blocks are available, assigns a new one to it[cite: 17, 23].
    * [cite_start]Once all blocks have been processed and all cores are done, the `dispatch` module asserts the top-level `done` signal[cite: 15, 16, 89], indicating the completion of the entire GPU task.
