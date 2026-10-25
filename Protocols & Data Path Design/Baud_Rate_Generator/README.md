# Baud Rate Generator

A parameterizable, synthesizable, high-precision **Baud Rate Generator** IP implemented in SystemVerilog.

This module provides both **1x Baud Ticks** (for UART/serial transmission) and **16x Oversampling Ticks** (for UART receiver edge synchronization and majority center-sampling), supporting dynamic hardware/software rate selection.

---

## 🌟 Key Features

- **Dual-Tick Outputs**:
  - `baud_tick`: 1-cycle pulse at $1 \times$ baud rate (for transmitter serialization).
  - `sample_tick`: 1-cycle pulse at $16 \times$ oversampling rate (for receiver center-aligned bit detection).
- **Runtime Dynamic Baud Rate Selection**:
  - 8 hardware presets via `baud_sel[2:0]` covering 9600 to 921600 baud.
- **Custom Programmable Divisor Mode**:
  - Support arbitrary, non-standard baud rates via `custom_div[15:0]` and `custom_en`.
- **Clock Gating / Low Power**:
  - Synchronous `enable` input pauses all tick generation and holds internal counters at zero.
- **Glitch-Free On-The-Fly Switching**:
  - Counter bounds protection (`sample_cnt >= target_div - 1`) prevents counter hang or extended latency when switching to a smaller divisor on-the-fly.

---

## 📐 Mathematical Formulation & Preset Table

Given system clock frequency $F_{\text{clk}}$ (default: 50 MHz) and oversampling ratio $O$ (default: 16):

$$\text{SAMPLE\_DIVISOR} = \text{round}\left(\frac{F_{\text{clk}}}{B \times O}\right) = \frac{F_{\text{clk}} + \frac{B \times O}{2}}{B \times O}$$

| `baud_sel` | Target Baud ($B$) | Ideal Divisor | Synthesized Divisor | Actual Baud Rate | Error % |
| :---: | :---: | :---: | :---: | :---: | :---: |
| `3'b000` | 9,600 | 325.52 | **326** | 9,585.8 | **-0.15%** |
| `3'b001` | 19,200 | 162.76 | **163** | 19,171.7 | **-0.15%** |
| `3'b010` | 38,400 | 81.38 | **81** | 38,580.2 | **+0.47%** |
| `3'b011` | 57,600 | 54.25 | **54** | 57,870.3 | **+0.47%** |
| `3'b100` | 115,200 | 27.12 | **27** | 115,740.7 | **+0.47%** |
| `3'b101` | 230,400 | 13.56 | **14** | 223,214.3 | **-3.12%** |
| `3'b110` | 460,800 | 6.78 | **7** | 446,428.6 | **-3.12%** |
| `3'b111` | 921,600 | 3.39 | **3** | 1,041,666.7 | **+13.0%** |

*(Note: For $\ge 921600$ baud, increasing $F_{\text{clk}}$ to 100 MHz or using 8x oversampling reduces error below 2.5%).*

---

## 📁 Folder Structure

```text
Baud_Rate_Generator/
├── src/
│   └── baud_rate_gen.sv    # Synthesizable Baud Rate Generator module
├── tb/
│   └── tb_baud_rate_gen.sv # Self-checking testbench
├── wave/
│   └── baud_rate_gen.vcd   # Simulation waveform output
└── README.md
```

---

## 🔌 Signal Interface

| Signal | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1 | System clock (e.g. 50 MHz) |
| `rst_n` | Input | 1 | Active-low asynchronous reset |
| `enable` | Input | 1 | Clock-gate enable (`1` = run, `0` = sleep) |
| `baud_sel` | Input | 3 | Preset selector (9600 to 921600) |
| `custom_div` | Input | 16 | User-defined integer divisor |
| `custom_en` | Input | 1 | When `1`, overrides `baud_sel` with `custom_div` |
| `sample_tick` | Output | 1 | 1-cycle pulse at $16 \times$ baud rate |
| `baud_tick` | Output | 1 | 1-cycle pulse at $1 \times$ baud rate |

---

## 🚀 How to Simulate

```powershell
# 1. Compile with Icarus Verilog
iverilog -g2012 -o tb_baud_rate_gen.vvp "src/baud_rate_gen.sv" "tb/tb_baud_rate_gen.sv"

# 2. Run simulation
vvp tb_baud_rate_gen.vvp

# 3. View waveforms (optional)
gtkwave "wave/baud_rate_gen.vcd"
```
