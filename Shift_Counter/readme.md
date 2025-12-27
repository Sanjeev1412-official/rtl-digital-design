# shift counters using verilog (ring counter & johnson counter)

## overview

this project implements two types of **shift-register-based counters** using **verilog hdl**:

- ring counter
- johnson counter (twisted ring counter)

shift counters generate predefined bit patterns using feedback logic instead of numeric counting.  
they are widely used in timing control, sequence generation, and one-hot state machines.

---

## ring counter

### description

a ring counter is a circular shift register where:
- a single ‘1’ bit circulates through the register
- only one bit is high at any time (one-hot encoding)
- number of valid states = n (number of flip-flops)

### example (4-bit)

`1000 → 0100 → 0010 → 0001 → 1000`

### key characteristics

- simple feedback (direct)
- requires correct reset initialization
- glitch-free transitions

## johnson counter

### description

a johnson counter is a modified ring counter where:
- inverted output of the last flip-flop is fed back
- generates twice the number of states compared to ring counter
- produces a smooth fill-and-empty bit pattern

### example (4-bit)

`0000 → 1000 → 1100 → 1110 → 1111 → 0111 → 0011 → 0001 → 0000`

### key characteristics

- inverted feedback
- 2n valid states
- only one bit changes per clock cycle

---

## comparison summary

| feature | ring counter | johnson counter |
|------|-------------|----------------|
| number of states | n | 2n |
| feedback type | direct | inverted |
| encoding | one-hot | pattern-based |
| reset requirement | mandatory | mandatory |

---

## commands

### johnson_counter

```bash
iverilog -o johnson_counter src/johnson_counter.v tb/tb_johnson_counter.v
vvp johnson_counter
gtkwave johnson_counter.vcd
```
### ring_counter

```bash
iverilog -o ring_counter src/ring_counter.v tb/tb_ring_counter.v
vvp ring_counter
gtkwave ring_counter.vcd
```
--- 

## learning outcomes

- understanding shift-register-based counters
- analyzing feedback-driven state machines
- designing glitch-free counters


