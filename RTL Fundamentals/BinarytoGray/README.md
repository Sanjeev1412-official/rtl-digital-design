# binary to gray code converter (4-bit) using verilog

## overview

this project implements a **4-bit binary to gray code converter** using **verilog hdl**.  
the design is **purely combinational** and converts a binary input into its corresponding gray code output.

gray code is widely used in digital systems to reduce switching errors, especially in:
- counters
- fifo pointers
- rotary encoders
- adc interfaces

---

## project objectives

- design a 4-bit binary to gray code converter
- understand xor-based encoding logic
- write synthesizable combinational rtl
- verify functionality using a testbench
- analyze output through waveform simulation

---

## binary to gray conversion rule

for a 4-bit binary input `bin[3:0]`, the gray code output `gray[3:0]` is generated as:
- `gray[3] = bin[3]`
- `gray[2] = bin[3] ^ bin[2]`
- `gray[1] = bin[2] ^ bin[1]`
- `gray[0] = bin[1] ^ bin[0]`

this ensures that **only one bit changes** between consecutive gray code values.

## conversion table (4-bit)

| binary | gray |
|-------|------|
| 0000  | 0000 |
| 0001  | 0001 |
| 0010  | 0011 |
| 0011  | 0010 |
| 0100  | 0110 |
| 0101  | 0111 |
| 0110  | 0101 |
| 0111  | 0100 |
| 1000  | 1100 |
| 1001  | 1101 |
| 1010  | 1111 |
| 1011  | 1110 |
| 1100  | 1010 |
| 1101  | 1011 |
| 1110  | 1001 |
| 1111  | 1000 |

---

## commands

```bash
iverilog -o bin_to_gray.vvp src/bin_to_gray_4bit.v tb/tb_bin_to_gray_4bit.v
vvp bin_to_gray.vvp
gtkwave bin_to_gray.vcd
```

## learning outcomes

- combinational rtl design
- encoding techniques using xor logic
- binary to gray code conversion
- writing and running testbenches
- waveform-based debugging using gtkwave

