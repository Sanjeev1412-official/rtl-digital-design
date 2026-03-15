# parameterized up/down counter with enable and reset (verilog)

## overview

this project implements a **parameterized synchronous up/down counter** using **verilog hdl**.  
the counter supports configurable bit width, enable control, direction control, and reset.


this project is intended for:
- understanding sequential logic and counters in verilog

---

## project features

- parameterized counter width (`N`)
- synchronous reset (active high)
- enable control
- up/down direction control
- clean sequential rtl design
- complete testbench
- waveform and console verification

---

## counter specification

| signal | description |
|------|------------|
| `clk` | clock input |
| `rst` | synchronous reset (active high) |
| `en` | enable signal |
| `up_down` | 1 = count up, 0 = count down |
| `count` | counter output |

priority order:
1. reset
2. enable
3. up/down operation

--- 

## commands

``` bash
iverilog -o up_down.vvp src/up_down_counter.v tb/tb_up_down_counter.v
vvp up_down.vvp
gtkwave up_down_counter.vcd

```

---

## learning outcomes

- sequential rtl design
- parameterized hardware modules
- synchronous reset handling
- enable and control logic
- clock-accurate testbench writing


