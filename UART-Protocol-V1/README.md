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

## 📌 Project Overview

This repository contains the **RTL design and verification of a complete UART (Universal Asynchronous Receiver Transmitter) system** implemented in **SystemVerilog**.
The project includes both a **UART Transmitter (TX)** and **UART Receiver (RX)**, along with a **UVM-like, class-based verification environment** to validate end-to-end serial communication.

The design and verification flow follows an **industry-inspired methodology**, emphasizing modular RTL design, structured verification, and self-checking simulations.

---

## 🎯 Objectives

* Design an **8-bit UART Transmitter and Receiver** in SystemVerilog
* Implement accurate **baud-rate timing** and **RX oversampling**
* Build a **reusable, self-checking verification environment**
* Validate correct serial communication through simulation
* Gain hands-on experience with **RTL design and SystemVerilog verification**

---

## ✨ UART Features

* 8-bit data transmission
* 1 start bit and 1 stop bit
* LSB-first transmission
* Configurable baud rate (default: **115200 bps**)
* **16× oversampling** in the receiver
* `busy` indication during transmission
* `valid_rx` pulse on successful reception

---

## 🧱 Design Architecture

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

## 🧪 Verification Environment

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

## ▶️ Simulation

**Simulation Tool:** QuestaSim

### To Run the Simulation

1. Compile all RTL and testbench files
2. Run the top-level testbench module
3. Observe PASS/FAIL messages from the scoreboard
4. View waveforms for TX, RX, sampling, and `valid_rx` signaling

### Successful Simulation Output (Excerpt)

```
[GEN] Data: P (50)
...
[MON] Received: P (50)
[SCB][PASS] Received P
...
[SCB][PASS] Received Y
[TB] Simulation completed.
```

A successful run confirms **end-to-end UART communication correctness**.

---

## 🔮 Future Enhancements

* Parity bit support
* Configurable stop bits
* UART error detection (framing, parity, overrun)
* Randomized and coverage-driven verification
* Full UVM-based testbench
* FPGA implementation and hardware validation

---

## 📚 References

* UART protocol tutorials and technical articles
* Open-source UART RTL implementations
* IEEE SystemVerilog standard documentation

---

## 📜 License

This project is licensed under the **MIT License**.
See the `LICENSE` file for details.

---

### ✅ Why This README Works Well

* Clear separation of **design** and **verification**
* Badge-based quick scanning for recruiters
* Strong technical depth without clutter
* Industry-aligned terminology and structure
* Easy to extend as the project grows

If you want next:

* A **short “For Recruiters” section**
* A **diagram section with embedded images**
* A **release/versioning section**
* README alignment with your **resume bullet points**

Just tell me.
