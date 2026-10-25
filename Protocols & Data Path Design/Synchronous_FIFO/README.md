# Synchronous FIFO Buffer

A parameterizable, synthesizable, high-throughput **Synchronous FIFO (First-In, First-Out) Buffer** implemented in SystemVerilog.

This FIFO serves as an elastic data buffer for cross-module rate-matching (e.g., between UART/SPI/I2C controllers and CPU/DMA cores).

---

## 🌟 Key Features

- **Circular Buffer Architecture**:
  - Independent write (`wr_ptr`) and read (`rd_ptr`) pointers with extra MSB wrap-around bit.
  - Power-of-2 depth support (`DEPTH = 2^N`) for efficient pointer math.
- **Full Capacity Simultaneous Read & Write**:
  - Allows simultaneous read and write operations even when `full` (read immediately opens a slot for the incoming write).
- **Watermark Flags**:
  - Programmable `almost_full` and `almost_empty` threshold detection for hardware flow control.
- **Safety Flags**:
  - Explicit `overflow` (attempted write when full) and `underflow` (attempted read when empty) pulses.
- **Self-Checking Testbench**:
  - Verifies reset state, fill to full, drain to empty, underflow/overflow protection, and concurrent streaming throughput.

---

## 📐 Architecture & Flag Logic

### 1. Pointer Mechanics
For a FIFO of `DEPTH = 16`, addresses require 4 bits (`[3:0]`). We allocate a 5-bit pointer (`[4:0]`):
- The lower 4 bits (`[3:0]`) index the memory array: `mem[wr_ptr[3:0]]`.
- The 5th bit (`[4]`) acts as a lap/wrap-around indicator:
  - **EMPTY**: Both pointers are completely identical:
    $$\text{wr\_ptr} == \text{rd\_ptr}$$
  - **FULL**: Lower address bits match, but the MSB is inverted:
    $$\text{wr\_ptr}[4] \neq \text{rd\_ptr}[4] \quad \text{and} \quad \text{wr\_ptr}[3:0] == \text{rd\_ptr}[3:0]$$

### 2. Occupancy Counter (`data_cnt`)
To cleanly support watermark thresholds (`almost_full`, `almost_empty`) and telemetry:
```systemverilog
case ({wr_valid, rd_valid})
    2'b10:   data_cnt <= data_cnt + 1'b1;
    2'b01:   data_cnt <= data_cnt - 1'b1;
    default: data_cnt <= data_cnt; // 2'b00 or simultaneous 2'b11
endcase
```

---

## 📁 Folder Structure

```text
Synchronous_FIFO/
├── src/
│   └── sync_fifo.sv       # Synthesizable Synchronous FIFO module
├── tb/
│   └── tb_sync_fifo.sv    # Self-checking testbench
├── wave/
│   └── sync_fifo.vcd      # Waveform output file
└── README.md
```

---

## 🔌 Signal Interface

| Signal | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 | Synchronous clock |
| `rst_n` | Input | 1 | Active-low asynchronous reset |
| `wr_en` | Input | 1 | Write enable |
| `wr_data` | Input | `DATA_WIDTH` | Data word to push into FIFO |
| `full` | Output | 1 | Asserted when FIFO has no free slots |
| `almost_full` | Output | 1 | Asserted when occupancy $\ge$ `ALMOST_FULL_THRESH` |
| `overflow` | Output | 1 | 1-cycle pulse on invalid write when full |
| `rd_en` | Input | 1 | Read enable |
| `rd_data` | Output | `DATA_WIDTH` | Registered data word popped from FIFO |
| `empty` | Output | 1 | Asserted when FIFO has no stored items |
| `almost_empty` | Output | 1 | Asserted when occupancy $\le$ `ALMOST_EMPTY_THRESH` |
| `underflow` | Output | 1 | 1-cycle pulse on invalid read when empty |
| `data_cnt` | Output | `[$clog2(DEPTH):0]` | Current item occupancy counter |

---

## 🚀 How to Simulate

```powershell
# 1. Compile with Icarus Verilog
iverilog -g2012 -o tb_sync_fifo.vvp "src/sync_fifo.sv" "tb/tb_sync_fifo.sv"

# 2. Run simulation
vvp tb_sync_fifo.vvp

# 3. View waveforms (optional)
gtkwave "wave/sync_fifo.vcd"
```
