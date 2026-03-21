# UART Transmitter + Receiver

This project implements a simple UART communication path in SystemVerilog.
It includes:

- a UART transmitter
- a UART receiver
- a baud-rate generator
- a top module that connects everything together
- a self-checking testbench with loopback verification

## What UART Is

UART stands for Universal Asynchronous Receiver Transmitter.

It is one of the simplest serial communication protocols. Instead of sending 8 bits at once on 8 wires, UART sends one bit at a time on a single wire.

Key ideas:

- Asynchronous means there is no shared clock between transmitter and receiver.
- Both sides must agree on the baud rate, which is the number of bits transferred per second.
- A UART frame usually contains:
	- 1 start bit
	- 8 data bits
	- 1 stop bit

In this project, the line is idle high, the start bit is low, and the stop bit is high.

## Project Goal

The goal of this design is to send an 8-bit value through the transmitter and receive the same value back through the receiver.

The testbench connects the transmit output directly to the receive input. This is called loopback testing.

## Folder Structure

```text
UART_Tx_Rx/
├── src/
│   ├── baud_gen.sv
│   ├── uart_rx.sv
│   ├── uart_top.sv
│   └── uart_tx.sv
├── tb/
│   └── uart_tb.sv
├── wave/
│   └── uart_tx_rx.vcd
└── README.md
```

## How To Simulate

Use a SystemVerilog-capable simulator such as Icarus Verilog.

Example command:

```bash
iverilog -g2012 -o uart_tb.vvp src/*.sv tb/uart_tb.sv
vvp uart_tb.vvp
```

## Notes On Timing

This design assumes:

- a 50 MHz clock
- 9,600 baud UART communication
- 16x receiver oversampling

The baud generator uses integer division, so the generated timing is slightly approximate. For a learning project, this is normal and acceptable.

## Learning Outcomes

After studying this project, you should understand:

- how a UART frame is built
- how serial data is transmitted one bit at a time
- how to use state machines in RTL
- how oversampling improves UART reception
- how to write a simple self-checking testbench

## Possible Improvements

If you want to extend this project, useful next steps are:

- add parity support
- make baud rate configurable from the top module
- add support for 7-bit or 9-bit data
- add framing error detection
- add a FIFO for buffering

