
# Traffic Light Controller FSM (SystemVerilog)

A parameterized **2-way traffic light controller** implemented as a **Moore finite state machine (FSM)** in SystemVerilog, with a self-check-friendly testbench and waveform (VCD) dump for debug/verification.

## Highlights

- **Moore FSM** with 4 states: NS green → NS yellow → EW green → EW yellow
- **Parameterized timing** via `GREEN_TIME` and `YELLOW_TIME`
- **Safe reset behavior**: when `rst=1`, outputs hold **all-red**
- **Clean outputs**: per direction, **exactly one** of {red, yellow, green} is asserted at a time
- Generates a **VCD waveform** for GTKWave or other viewers

## Design Specification

### States

| State | North–South | East–West |
|------:|-------------|----------|
| `S0_NS_GREEN`  | Green  | Red    |
| `S1_NS_YELLOW` | Yellow | Red    |
| `S2_EW_GREEN`  | Red    | Green  |
| `S3_EW_YELLOW` | Red    | Yellow |

### Timing

- The controller stays in each **green** state for `GREEN_TIME` cycles.
- The controller stays in each **yellow** state for `YELLOW_TIME` cycles.
- A simple internal `timer` counts cycles and triggers state transitions.

## Interface

Module: `traffic_light_fsm`

Inputs:
- `clk`: clock
- `rst`: **active-high reset** (holds controller in safe all-red output)

Outputs (active-high):
- North–South: `ns_red`, `ns_yellow`, `ns_green`
- East–West: `ew_red`, `ew_yellow`, `ew_green`

## Project Structure

| Path | Description |
|------|-------------|
| [src/traffic_light_fsm.sv](src/traffic_light_fsm.sv) | FSM RTL implementation |
| [tb/tb_traffic_light_fsm.sv](tb/tb_traffic_light_fsm.sv) | Testbench + VCD dump |
| [wave/](wave/) | Simulation outputs (VCD) |

## How to Run (Icarus Verilog)

From the `Trafficlight_FSM/` folder:

```bash
iverilog -g2012 -o tlc.vvp .\src\traffic_light_fsm.sv .\tb\tb_traffic_light_fsm.sv
vvp .\tlc.vvp
```

This produces:
- Console trace of the light outputs each clock edge
- Waveform file: `wave/traffic_light_fsm.vcd`

### View Waveform

Open the VCD using GTKWave:

```bash
gtkwave .\wave\traffic_light_fsm.vcd
```

## Expected Behavior (Quick Sanity)

During reset (`rst=1`):
- `ns_red=1`, `ew_red=1`, and all yellow/green are `0`

After reset deasserted (`rst=0`):
- NS green for `GREEN_TIME` cycles
- NS yellow for `YELLOW_TIME` cycles
- EW green for `GREEN_TIME` cycles
- EW yellow for `YELLOW_TIME` cycles
- Repeat

## Notes

- The testbench uses `$strobe` so printed values reflect the post-clock-update signals.
- This module is intended as a clean, readable RTL example suitable for interviews and portfolio review.

