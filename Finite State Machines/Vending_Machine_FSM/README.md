
# Vending Machine FSM (SystemVerilog)

A simple **vending machine controller** implemented in **SystemVerilog** using a finite state machine (FSM). The design accepts **₹5** and **₹10** coins, **dispenses a product at ₹15**, and returns **₹5 change** when the inserted amount reaches ₹20.

## Highlights

- Clear FSM state model for accumulated credit: ₹0 / ₹5 / ₹10 / ₹15 / ₹20

## Design Specification

### Inputs

- `coin_5`: pulse high for one clock to insert ₹5
- `coin_10`: pulse high for one clock to insert ₹10
- `rst`: active-high reset

### Outputs

- `dispense`: asserted when product is dispensed
- `change_5`: asserted when ₹5 change should be returned

### Behavior

- Accumulates inserted credit in steps of ₹5/₹10.
- When credit reaches **₹15**: `dispense=1` for one cycle, then returns to idle.
- When credit reaches **₹20**: `dispense=1` and `change_5=1` for one cycle, then returns to idle.

The current RTL is a **Moore-style output**, so outputs assert based on the current state.

## How to Run (Icarus Verilog)


```bash
iverilog -g2012 -o vending_machine.vvp .Vending_Machine_FSM\src\vending_machine.sv .Vending_Machine_FSM\tb\tb_vending_machine.sv
vvp .\vending_machine.vvp
gtkwave .\wave\vending_machine.vcd
```


## Expected Simulation Trace (Example)

Typical sequences you should observe:

- Insert ₹5 then ₹10 → `dispense` asserts (₹15 reached)
- Insert ₹10 then ₹10 → `dispense` and `change_5` assert (₹20 reached)

The testbench prints signals on each rising clock edge using `$strobe`.

## Learning Outcomes (SystemVerilog)

- Modeling FSMs with `typedef enum logic` state encoding
- Separating sequential (`always_ff`) and combinational (`always_comb`) logic
- Writing clean next-state logic with explicit defaults to avoid latches
- Understanding Moore outputs and cycle-accurate stimulus in a testbench

