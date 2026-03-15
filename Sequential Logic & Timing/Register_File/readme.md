# Register File (Parametric)

A simple **parametric register file** implemented in Verilog with:
- **Synchronous write** on `posedge clk` when `we=1`
- **Synchronous reset** on `posedge clk` when `rst=1` (clears all registers)
- **Two asynchronous read ports** (combinational reads)

This module is useful as a building block for small CPU/MCU datapaths and digital design practice.

---

## Design Summary

- Storage: `DEPTH` registers, each `DATA_WIDTH` bits wide
- Write: single port, clocked
- Read: two independent ports, combinational

---

## Module Interface

### Parameters

- `DATA_WIDTH` (default: 8): Width of each register in bits
- `ADDR_WIDTH` (default: 4): Address width
- `DEPTH` (default: `1 << ADDR_WIDTH`): Number of registers

### Ports

- Inputs
	- `clk` : Clock
	- `rst` : Synchronous reset (active high)
	- `we` : Write enable
	- `read_addr1` : Read address for port 1
	- `read_addr2` : Read address for port 2
	- `write_addr` : Write address
	- `write_data` : Data to write

- Outputs
	- `read_data1` : Data read from `read_addr1`
	- `read_data2` : Data read from `read_addr2`

---

## How It Works

- On every rising clock edge:
	- If `rst=1`, all registers are cleared to `0`
	- Else if `we=1`, `write_data` is stored into `reg_array[write_addr]`
- Reads are continuously driven:
	- `read_data1 = reg_array[read_addr1]`
	- `read_data2 = reg_array[read_addr2]`

---

## commands

```bash
iverilog -o reg_file.vvp Register_File\src\reg_file.v Register_File\tb\tb_reg_file.v
vvp reg_file.vvp
gtkwave wave\reg_file.vcd
```

---

## Learning Outcomes

- Use Verilog parameters (`DATA_WIDTH`, `ADDR_WIDTH`) to build scalable RTL
- Implement a synthesizable memory/register array using `reg [W-1:0] array [0:N-1]`
- Differentiate **combinational (asynchronous) reads** vs **clocked (synchronous) writes**
- Write a synchronous reset loop to initialize a register array
- Create and run a basic testbench, generate a VCD file, and inspect waveforms in GTKWave


