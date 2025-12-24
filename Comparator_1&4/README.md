# magnitude comparator using verilog (>, <, =)

## overview

this project implements a **comparator** using **verilog hdl**.  
the comparator compares two inputs and generates three mutually exclusive outputs:

- `gt` → a > b  
- `lt` → a < b  
- `eq` → a == b  

both **1-bit** and **4-bit** comparators are designed and verified through simulation.

---

## project objectives

- design a 1-bit comparator
- design a 4-bit comparator
- ensure mutually exclusive outputs (gt, lt, eq)
- verify functionality using waveform simulation

---

## 1-bit comparator

### truth table

| a | b | gt | lt | eq |
|---|---|----|----|----|
| 0 | 0 | 0  | 0  | 1  |
| 0 | 1 | 0  | 1  | 0  |
| 1 | 0 | 1  | 0  | 0  |
| 1 | 1 | 0  | 0  | 1  |

## 4-bit comparator

### truth table

| a | b | gt | lt | eq |
|---|---|----|----|----|
| 10 | 5 | 1  | 0  | 0  |
| 3 | 7 | 0  | 1  | 0  |
| 12 | 12 | 0  | 0  | 1  |
| 0 | 0 | 0  | 0  | 1  |
| 15 | 14 | 1  | 0  | 0  |
| 8 | 9 | 0  | 1  | 0 |

---

## commands

### 1-bit comparator

``` bash
iverilog -o comp_1bit.vvp src/comp_1bit_case.v tb/tb_comp_1bit.v
vvp comp_1bit.vvp
gtkwave comp_1bit.vcd

```

### 4-bit comparator

``` bash
iverilog -o comp_4bit.vvp src/comp_1bit_case.v tb/tb_comp_1bit.v
vvp comp_4bit.vvp
gtkwave comp_1bit.vcd

```
---


## learning outcomes

- combinational rtl design
- case-based decision logic
- magnitude comparison using verilog


