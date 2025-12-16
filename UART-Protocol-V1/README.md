# SystemVerilog Design and Verification of UART Transmitter and Receiver

<p align="center">
  <img src="https://img.shields.io/badge/Language-SystemVerilog-blue"/>
  <img src="https://img.shields.io/badge/Design-RTL-green"/>
  <img src="https://img.shields.io/badge/Verification-UVM--Like-orange"/>
  <img src="https://img.shields.io/badge/Protocol-UART-success"/>
  <img src="https://img.shields.io/badge/Simulator-QuestaSim-purple"/>
  <img src="https://img.shields.io/badge/License-MIT-brightgreen"/>
</p>

---

## Project Overview

This repository contains the **RTL design and verification of a complete UART (Universal Asynchronous Receiver Transmitter) system** implemented in **SystemVerilog**.
The project includes both a **UART Transmitter (TX)** and **UART Receiver (RX)**, along with a **UVM-like, class-based verification environment** to validate end-to-end serial communication.

The design and verification flow follows an **industry-inspired methodology**, emphasizing modular RTL design, structured verification, and self-checking simulations.

---

## Objectives

* Design an **8-bit UART Transmitter and Receiver** in SystemVerilog
* Implement accurate **baud-rate timing** and **RX oversampling**
* Build a **reusable, self-checking verification environment**
* Validate correct serial communication through simulation
* Gain hands-on experience with **RTL design and SystemVerilog verification**

---

## UART Features

* 8-bit data transmission
* 1 start bit and 1 stop bit
* LSB-first transmission
* Configurable baud rate (default: **115200 bps**)
* **16× oversampling** in the receiver
* `busy` indication during transmission
* `valid_rx` pulse on successful reception

---

## Design Architecture

### UART Transmitter (`uart_tx`)

* Parallel-to-serial conversion using a **10-bit shift register**
* Baud-rate divider for precise bit timing
* Bit index counter to control transmission sequence
* `busy` flag to prevent overlapping transmissions

### UART Receiver (`uart_rx`)

* Start-bit detection
* **16× oversampling** for reliable sampling
* Mid-bit sampling strategy
* Bit counter and sample counter
* Shift register to reconstruct received data
* Stop-bit validation and `valid_rx` signaling

---

## Verification Environment

A **UVM-like verification environment** was implemented using SystemVerilog classes:

* **Interface (`inf_uart`)** – Groups all DUT signals
* **Transaction (`uart_transaction`)** – Represents one UART data transfer
* **Generator** – Produces stimulus data
* **Driver** – Drives transactions into the DUT
* **Monitor** – Observes RX output and captures received data
* **Scoreboard** – Compares expected and actual results
* **Environment** – Connects and manages all verification components
* **Testbench** – Instantiates DUT, environment, clock, and reset

### Test Scenario

The testbench sends the message:

```
"PORTLAND STATE UNIVERSITY"
```

and verifies correct reception using a **self-checking scoreboard**.

---

## Simulation

**Simulation Tool:** QuestaSim

### To Run the Simulation

1. Compile all RTL and testbench files
2. Run the top-level testbench module
3. Observe PASS/FAIL messages from the scoreboard
4. View waveforms for TX, RX, sampling, and `valid_rx` signaling

### Successful Simulation Output (Excerpt)

```
# [GEN] Data: P (50)
# [GEN] Data: O (4f)
# [GEN] Data: R (52)
# [GEN] Data: T (54)
# [GEN] Data: L (4c)
# [GEN] Data: A (41)
# [GEN] Data: N (4e)
# [GEN] Data: D (44)
# [GEN] Data:   (20)
# [GEN] Data: S (53)
# [GEN] Data: T (54)
# [GEN] Data: A (41)
# [GEN] Data: T (54)
# [GEN] Data: E (45)
# [GEN] Data:   (20)
# [GEN] Data: U (55)
# [GEN] Data: N (4e)
# [GEN] Data: I (49)
# [GEN] Data: V (56)
# [GEN] Data: E (45)
# [GEN] Data: R (52)
# [GEN] Data: S (53)
# [GEN] Data: I (49)
# [GEN] Data: T (54)
# [GEN] Data: Y (59)
# [MON] Received: P (50)
# [SCB][PASS] Received P
# [MON] Received: O (4f)
# [SCB][PASS] Received O
# [MON] Received: R (52)
# [SCB][PASS] Received R
# [MON] Received: T (54)
# [SCB][PASS] Received T
# [MON] Received: L (4c)
# [SCB][PASS] Received L
# [MON] Received: A (41)
# [SCB][PASS] Received A
# [MON] Received: N (4e)
# [SCB][PASS] Received N
# [MON] Received: D (44)
# [SCB][PASS] Received D
# [MON] Received:   (20)
# [SCB][PASS] Received  
# [MON] Received: S (53)
# [SCB][PASS] Received S
# [MON] Received: T (54)
# [SCB][PASS] Received T
# [MON] Received: A (41)
# [SCB][PASS] Received A
# [MON] Received: T (54)
# [SCB][PASS] Received T
# [MON] Received: E (45)
# [SCB][PASS] Received E
# [MON] Received:   (20)
# [SCB][PASS] Received  
# [MON] Received: U (55)
# [SCB][PASS] Received U
# [MON] Received: N (4e)
# [SCB][PASS] Received N
# [MON] Received: I (49)
# [SCB][PASS] Received I
# [MON] Received: V (56)
# [SCB][PASS] Received V
# [MON] Received: E (45)
# [SCB][PASS] Received E
# [MON] Received: R (52)
# [SCB][PASS] Received R
# [MON] Received: S (53)
# [SCB][PASS] Received S
# [MON] Received: I (49)
# [SCB][PASS] Received I
# [MON] Received: T (54)
# [SCB][PASS] Received T
# [MON] Received: Y (59)
# [SCB][PASS] Received Y
# [TB] Simulation completed.
```

A successful run confirms **end-to-end UART communication correctness**.

---

## Future Enhancements

* Parity bit support
* Configurable stop bits
* UART error detection (framing, parity, overrun)
* Randomized and coverage-driven verification
* Full UVM-based testbench
* FPGA implementation and hardware validation

---

## References

* UART protocol tutorials and technical articles
* Open-source UART RTL implementations
* IEEE SystemVerilog standard documentation

---

## License

This project is licensed under the **MIT License**.
See the `LICENSE` file for details.

---

