# 8-bit ALU Design in Verilog

## Overview
This project implements a **combinational 8-bit Arithmetic Logic Unit (ALU)** using Verilog HDL.  
The design supports basic arithmetic and logical operations and is verified using a self-written testbench and waveform analysis.

This project was built to strengthen **RTL design fundamentals**, **hardware thinking**, and **verification skills**, which are essential for entry-level VLSI / Digital Design roles.

---

## Features
- 8-bit wide ALU design
- Supported operations:
  - Addition
  - Subtraction
  - Bitwise AND
  - Bitwise OR
- Status flags:
  - Carry flag
  - Zero flag
- Fully combinational RTL (no clock, no storage elements)
- Verified using Icarus Verilog simulation
- Waveform analysis using VCD viewer / GTKWave / Digital IDE

---

## ALU Specification

### Inputs
| Signal | Width | Description |
|------|------|------------|
| `a` | 8-bit | First operand |
| `b` | 8-bit | Second operand |
| `opcode` | 2-bit | Operation select |

### Outputs
| Signal | Width | Description |
|-------|-------|------------|
| `y` | 8-bit | ALU result |
| `carryout` | 1-bit | Carry / borrow flag |
| `zero` | 1-bit | Asserted when result is zero |

### Opcode Mapping
| Opcode | Operation |
|------|-----------|
| `00` | Addition |
| `01` | Subtraction |
| `10` | AND |
| `11` | OR |

---

## Project Structure


## Simulation & Verification

### Tools Used
- Icarus Verilog (iverilog, vvp)
- GTKWave / Digital IDE VCD Viewer
- VS Code (Digital IDE extension)

### Compile
```bash
iverilog -o alu_sim.vvp src/8bit_alu.v testbench/8bit_alu_tb.v
```
### Run Simulation
```bash
vvp alu_sim.vvp
```
### View Waveform
```bash
gtkwave wave/alu.vcd
```

## Verification Approach

- Directed test cases applied for each opcode
- Overflow and edge cases tested
- Outputs verified using:
  - Console output using `$display`
  - Waveform inspection using VCD viewer
- Zero and carry flags validated for correctness across all operations

---

## Learning Outcomes

Through this project, I gained hands-on experience with:

- RTL design using Verilog HDL
- Modeling combinational logic circuits
- Case-based operation selection (MUX-based design)
- Writing structured and readable testbenches
- Debugging and validating designs using waveform analysis

