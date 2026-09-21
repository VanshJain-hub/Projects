# 🖥️ Single-Cycle RV32I RISC-V Processor

![Verilog](https://img.shields.io/badge/Language-Verilog-blue)
![Status](https://img.shields.io/badge/Status-Verified-green)
![Architecture](https://img.shields.io/badge/Architecture-RISC--V-orange)

## 📜 Abstract
This repository contains the RTL implementation and verification of a **32-bit Single-Cycle Processor** based on the **RISC-V RV32I Base Integer Instruction Set Architecture**.

Designed from scratch in Verilog, this core supports the complete set of integer instructions, including arithmetic, logic, memory access (byte/half-word/word), and control flow operations. The design focuses on robust signal handling, precise decoding logic, and a "Smart Memory" subsystem for handling misaligned or sub-word data access.

---

## 🚀 Features

### ✅ Supported Instruction Formats
The processor is fully compliant with the RV32I standard, supporting:
- **R-Type:** `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`
- **I-Type:** `ADDI`, `LW`, `LB`, `LH`, `LBU`, `LHU`, `JALR`, `SLTI`, `SLTIU`
- **S-Type:** `SW`, `SB`, `SH`
- **B-Type:** `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`
- **U-Type:** `LUI`, `AUIPC`
- **J-Type:** `JAL`

### 🧠 Key Architecture Highlights
- **Modular Design:** Distinct Datapath and Control Unit (Main & ALU Decoder).
- **Smart Memory Controller:** Handles `Load Byte` (LB) and `Load Half` (LH) with dynamic **Sign Extension** vs. **Zero Extension** logic.
- **Dedicated ALU:** Supports both Logical (`>>`) and Arithmetic (`>>>`) shifts, as well as signed vs. unsigned comparisons.

---

## 🛠️ Implementation Details & Challenges

During the design phase, several complex engineering challenges ("Speedbreakers") were solved:

### 1. Control Logic Synthesis
**Challenge:** The decoding logic initially misinterpreted `ADDI` (Immediate Add) as `SUB` (Subtract) because the negative immediate value set the 30th bit high.
**Solution:** Refined the ALU Decoder to strictly differentiate R-Type and I-Type opcodes using `Instr[5]`, preventing false positive subtractions.

### 2. Shift Logic Inversion
**Challenge:** `SRL` (Logical Right) and `SRA` (Arithmetic Right) were initially swapped.
**Solution:** Corrected the `funct7` decoding logic to ensure `SRA` preserves the sign bit (filling with 1s for negative numbers) while `SRL` zero-fills.

### 3. Memory Granularity
**Challenge:** Standard memory modules operate on 32-bit words, causing `SB` (Store Byte) to corrupt neighboring bytes.
**Solution:** Implemented Read-Modify-Write logic within the memory module to target specific byte offsets without affecting the rest of the word.

---

## 📊 Verification

The processor was verified using **GTKWave** with custom assembly test suites.

### Test Case: "The Advanced Operations Test" (`test_prog_FULL2.hex`)
This scenario tested the processor's ability to handle complex instruction sequences, including:
1.  **Upper Immediates:** Loading 20-bit values into the MSB (`LUI`).
2.  **Computed Jumps:** Jumping to an address calculated in a register (`JALR`).
3.  **Unsigned Comparisons:** Correctly identifying that `0 < -1` when treating -1 as an unsigned huge number (`SLTU`).
4.  **Bitwise Shifts:** Verifying the difference between arithmetic and logical shifts.

### 📷 Waveform Results
*The following waveform demonstrates the successful execution of the Advanced Operations Test. Note `x31` asserting High (1) at the end, indicating success.*

![Final Verification Waveform](screenshots/image_c145c7.png)
*(Ensure you create a 'screenshots' folder and place your image there)*

---

## 📂 File Structure

The project is organized as a flat directory structure containing all Verilog source modules, testbenches, and hexadecimal memory files.

```text
├── Top Level & Testbench
│   ├── top_module.v          # Top-level wrapper connecting Data & Control paths
│   ├── top_tb.v              # Main Testbench
│
├── Core Modules
│   ├── datapath.v            # Main Datapath Unit
│   ├── controlpath.v         # Main Control Unit
│   ├── ALU.v                 # Arithmetic Logic Unit
│   ├── ALU_Decoder.v         # ALU Control Signal Decoder
│   ├── Main_Decoder.v        # Main Opcode Decoder
│   ├── register_file.v       # 32x32 Register File
│   ├── data_memory.v         # Data Memory (RAM)
│   ├── instruction_memory.v  # Instruction Memory (ROM)
│   ├── Sign_Extender.v       # Immediate Generator
│   ├── PC_Reg.v              # Program Counter Register
│   ├── PC_Plus_4.v           # PC Adder
│   ├── PC_Target.v           # Branch Target Adder
│   └── seven_seg.v           # Seven Segment Display Controller (Optional)
│
├── Multiplexers
│   ├── ALU_Mux.v
│   ├── PC_Mux.v
│   └── Result_Mux.v
│
├── Verification Files (Hex Code)
│   ├── test_prog_FULL2.hex   # Final "Advanced Operations" Test
│   ├── test_prog_FULL.hex    # Complete ISA Test
│   ├── test_prog_branch.hex  # Branching Logic Test
│   ├── test_prog_LoadStore.hex # Memory Access Test
│   ├── test_prog_jal.hex     # Jump Logic Test
│   └── test_prog_LUI.hex     # Upper Immediate Test
│
└── Outputs
    └── execute.vcd           # GTKWave Simulation Dump