# shift registers using verilog (siso, sipo, piso)

## overview

this project implements three fundamental types of **shift registers** using **verilog hdl**:

- siso (serial in serial out)
- sipo (serial in parallel out)
- piso (parallel in serial out)

shift registers are core sequential building blocks used for data movement, serialization, deserialization, and timing alignment in digital systems.

---

## types of shift registers

### 1. siso – serial in serial out
- one bit enters per clock
- one bit exits per clock
- acts as a pipeline delay
- output is a delayed version of input

**use cases:**
- data delay lines
- serial pipelines

---

### 2. sipo – serial in parallel out
- serial data collected into a parallel word
- after n clocks, full data available

**use cases:**
- uart receiver
- spi / i2c receivers
- deserializers

---

### 3. piso – parallel in serial out
- parallel data loaded in one clock
- data shifted out serially

**use cases:**
- uart transmitter
- serializers
- communication interfaces

---

## commands

### siso

```bash
iverilog -o siso src/siso.v tb/tb_siso.v
vvp siso
gtkwave siso.vcd
```

### sipo

```bash
iverilog -o sipo src/sipo.v tb/tb_sipo.v
vvp sipo
gtkwave sipo.vcd
```

### piso

```bash
iverilog -o piso src/piso.v tb/tb_piso.v
vvp piso
gtkwave piso.vcd
```

## learning outcomes

- how data moves through flip-flops
- difference between serial and parallel data paths
- shift direction and bit ordering
- role of clock in sequential circuits
- writing clock-accurate testbenches
- waveform-based debugging

