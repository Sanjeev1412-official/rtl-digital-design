# Parameterized N-Bit Adder (Verilog HDL)

A **parameterized combinational N-bit binary adder** implemented in **Verilog HDL**, designed to support **scalable bit-widths** (4-bit, 8-bit, 16-bit, 32-bit, etc.) using a single reusable module.

---

## 📌 Features

- Parameterized design using `parameter N`
- Supports arbitrary bit-widths without rewriting logic
- Pure combinational logic (no clock dependency)
- Carry-out support for overflow detection
- Complete and structured Verilog testbench
- Simulation using **Icarus Verilog**
- Waveform verification using **GTKWave**

---

## 🧠 Concept Overview

Binary addition is implemented using Verilog’s arithmetic operator (`+`), which synthesizes to optimized adder hardware during synthesis.

For an N-bit adder:
- **Inputs**: `a[N-1:0]`, `b[N-1:0]`, `cin`
- **Outputs**: `sum[N-1:0]`, `cout`
- An internal extended signal is used to correctly capture carry overflow

---

## Compile

``` bash
iverilog -o adder_sim src/n_bit_adder.v tb/n_bit_adder_tb.v
```

## Run Simulation

``` bash
vvp adder_sim
```

## View Waveform

``` bash
gtkwave adder.vcd
```

---

## Scalability Demonstration
``` bash
parameter N = 16;
```

- 4-bit adder
- 8-bit adder
- 16-bit adder
- 32-bit adder
  
This confirms true parameterized RTL design.

---

## Learning Outcomes

- Understanding of parameterized RTL modules
- Practical Verilog simulation workflow
- Writing structured testbenches
- Debugging using waveform analysis
- Industry-style coding discipline
