# 2:1 and 4:1 multiplexer using case statement

## overview

this project implements **2:1 and 4:1 multiplexers** using the **case statement in verilog**.  
the design is fully **combinational**, verified using **testbenches and waveform simulation**.

---

## project objectives

- design a 2:1 multiplexer using `case`
- design a 4:1 multiplexer using `case`
- simulate and verify functionality using iverilog and gtkwave

---


## 2:1 multiplexer design

### truth table

| selection | output |
|----|--------|
| 0  | a      |
| 1  | b      |

---

## 4:1 multiplexer design

### truth table

| selection | output |
| --- | ------ |
| 00  | a     |
| 01  | b     |
| 10  | c     |
| 11  | d     |

---

## commands

### 2:1 multiplexer

```bash
iverilog -o mux_2to1.vvp src/mux_2to1_case.v tb/tb_mux_2to1.v
vvp mux_2to1.vvp
gtkwave mux_2to1.vcd

```
### 4:1 multiplexer

```bash
iverilog -o mux_4to1.vvp src/mux_4to1_case.v tb/tb_mux_4to1.v
vvp mux_4to1
gtkwave mux_4to1.vcd

```

---

## learning outcomes

- combinational rtl design using verilog
- implementing selection logic using case statements
- writing structured testbenches
- waveform-based debugging using gtkwave
- basic rtl project organization for github
