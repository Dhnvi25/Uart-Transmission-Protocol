# UART Controller with 16× Oversampling (Verilog)

## Overview

This project is a **UART (Universal Asynchronous Receiver Transmitter) controller implemented entirely in Verilog-2001** and simulated using **Xilinx Vivado**. The design is in **parameterized baud communication with 16× oversampling**, making the receiver more robust against timing mismatches and asynchronous input sampling issues.

The project was developed as a **frontend VLSI / RTL design exercise**, focusing not only on writing synthesizable RTL but also on **systematic debugging, timing verification, and waveform-based validation**.

---

## Features

* **Verilog-2001 implementation** (no SystemVerilog dependencies)
* **1,00,000Hz system clock**
* **100 baud rate**
* **8N1 UART format**
* **16× oversampling receiver**
* **Loopback verification testbench**
* Synthesizable RTL suitable for FPGA implementation

---

## Project Structure

```text
├── baud_gen.v         # Baud rate and oversampling tick generator
├── uart_tx.v          # UART transmitter FSM
├── uart_rx.v          # UART receiver FSM with 16× oversampling
├── uart_top.v         # Top-level integration module
├── tb_uart_top.v      # Vivado simulation testbench
└── README.md
```

---

## Architecture

### 1. Baud Rate Generator

Generates two timing pulses from the 1,00,000Hz FPGA clock:

* **baud_tick** → 100 Hz
* **oversample_tick** → 1600Hz (16× baud)

These pulses are used by the transmitter and receiver FSMs respectively.

---

### 2. UART Transmitter

Finite State Machine:

```text
IDLE → START → DATA → STOP
```

* Loads parallel data when `tx_start` is asserted.
* Holds each serial bit for **one baud period**.
* Transmits **LSB first** as required by the UART protocol.

---

### 3. UART Receiver

The receiver uses **16× oversampling**:

1. Detect falling edge of the start bit.
2. Wait **8 oversample ticks** to reach the center of the start bit.
3. Sample each data bit every **16 ticks**.
4. Validate the stop bit.
5. Assert `rx_done` and update `rx_data`.

This approach provides much better reliability than single-sample UART receivers.

---

## Debugging Journey

A large portion of the work involved **iterative debugging in Vivado**. Some of the issues encountered were:

### Port Mismatch Errors

```text
cannot find port 'rx_data'
cannot find port 'oversample_tick'
```
**Cause:** Old UART modules were still present in the Vivado project, causing conflicting module definitions.
**Fix:** Removed legacy source files and rebuilt the project with a clean hierarchy.
---

### Simulation Elaboration Failure

```text
Static elaboration of top level Verilog design unit(s) failed
```
**Cause:** Top module names did not match the instantiated module names in the testbench.
**Fix:** Standardized all module names and ensured the simulation top was set correctly.
---

### No UART Activity in Waveform

Initial waveforms showed:

```text
tx = 1
tx_busy = 0
rx_done = 0
```

**Cause:** Simulation was stopping at **1 µs**, while a single UART frame at 115200 baud requires about **86.8 µs**.

**Fix:** Increased simulation runtime to hundreds of microseconds.

---

### Consecutive Transmission Failure

Only the first byte (`0x55`) was received correctly.
**Cause:** The testbench attempted to start a new transmission before the transmitter had fully returned to the `IDLE` state, and synchronization using `wait(rx_done)` missed short pulses.
**Fix:** Reworked the testbench to perform **independent loopback tests with a full reset between transmissions**.
---

## Final Verification

### Test Sequence

| Test | Transmitted | Received |
| ---- | ----------- | -------- |
| 1    | `8'h55`     | `8'h55`  |
| 2    | `8'hA3`     | `8'hA3`  |
| 3    | `8'h3C`     | `8'h3C`  |

Each test performs:

```text
Reset → Transmit → Receive → Verify → Reset
```

This ensures complete isolation between test cases and makes debugging much easier.

---

## Tools Used

* **Xilinx Vivado**
* **XSIM (Vivado Simulator)**
* **Verilog-2001**
* Waveform debugging using the Vivado waveform viewer

---

## What I Learned

This project was not just about implementing UART; it became an exercise in **practical RTL debugging**. The most valuable lessons were:

* Difference between **clock signals and enable pulses**
* Importance of **clean reset sequencing**
* Why **16× oversampling** is used in real UART receivers
* Handling **one-cycle handshake pulses** safely
* Using **waveform analysis to isolate timing bugs**
* Maintaining a **clean Vivado project hierarchy** to avoid module conflicts

---

## Future Improvements

Possible extensions include:

* Parity bit support
* Configurable baud rates
* FIFO buffering
* Interrupt-style status flags
* AXI-Lite or APB interface for SoC integration
* FPGA board validation using USB-UART hardware

---

## Conclusion

This project successfully implements a **fully functional UART controller with 16× oversampling in Verilog** and demonstrates a complete **RTL design → simulation → debugging → verification workflow**. The extensive debugging process, including resolving simulation, synchronization, and timing issues, provided significant hands-on experience with **frontend VLSI design practices and FPGA-based verification methodologies**.

---

### Author

**Dhanvi Prasada**
