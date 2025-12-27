# clock divider / frequency divider using verilog

## overview

this project implements a **parameterized clock divider (frequency divider)** using **verilog hdl**.  
the design takes a high-frequency input clock and generates a lower-frequency output clock using **counter-based sequential logic**.

clock dividers are fundamental building blocks in digital systems and are commonly used in:
- baud rate generators
- clock scaling
- timing control logic
- digital communication systems
- pll / clock management blocks

---

## project objectives

- design a clock divider using sequential logic
- understand counter-based frequency division
- use parameters to control division factor
- implement proper reset behavior
- verify output frequency using waveform simulation

---

## clock divider concept

a clock divider reduces the frequency of an input clock.

for a division factor `N`:
- output clock period = `N × input clock period`
- output clock frequency = `input frequency / N`

this design assumes **DIV is even** to maintain a 50% duty cycle.

---

## design parameters

| parameter | description |
|---------|-------------|
| `N` | division factor (must be even) |

---

## signal description

| signal | description |
|------|------------|
| `clk_in` | input clock |
| `rst` | synchronous reset (active high) |
| `clk_out` | divided output clock |

---

## design explanation

- a counter tracks the number of input clock cycles
- when the counter reaches (DIV/2 - 1), the output clock toggles
- toggling twice completes one full output clock period
- reset initializes both the counter and output clock
- all logic is synchronous to clk_in

## commands

``` bash
iverilog -o clock_divider.vvp src/clock_divider.v tb/tb_clock_divider.v
vvp clock_divider.vvp
gtkwave clock_divider.vcd

```

## learning outcomes

- clocked sequential rtl design
- counter-based timing logic
- parameterized hardware modules
- reset and initialization discipline
- waveform-based verification
- frequency and timing analysis
