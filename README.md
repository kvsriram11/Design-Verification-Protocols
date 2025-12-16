# Design-Verification-Protocols

![SystemVerilog](https://img.shields.io/badge/SystemVerilog-RTL%20%7C%20Verification-blue)
![Verification](https://img.shields.io/badge/Verification-UVM--Like-orange)
![Simulator](https://img.shields.io/badge/Simulator-QuestaSim-green)
![License](https://img.shields.io/badge/License-MIT-brightgreen)
![Status](https://img.shields.io/badge/Status-Active%20Development-yellow)
![CI](https://github.com/kvsriram11/Design-Verification-Protocols/actions/workflows/simulation.yml/badge.svg)

---

## Overview

**Design-Verification-Protocols** is a growing repository of **digital communication protocol implementations** developed using **SystemVerilog**, with equal emphasis on **RTL design** and **functional verification**.

The goal of this repository is to demonstrate:

* Industry-style protocol design methodologies
* Clean, modular, and parameterized RTL
* Structured, self-checking verification environments
* Clear documentation and reproducible simulations

Each protocol is implemented end-to-end, from **specification to verification**, closely following workflows used in professional hardware design and verification teams.

---

## Key Highlights

* Written entirely in **SystemVerilog**
* Clean separation of **design (RTL)** and **verification (TB)**
* UVM-like verification architecture using:

  * Transactions
  * Generator
  * Driver
  * Monitor
  * Scoreboard
  * Environment
* Self-checking simulations with PASS/FAIL reporting
* Ready for extension to additional protocols

---

## Implemented Protocols

### UART (Universal Asynchronous Receiver/Transmitter)

The first protocol implemented in this repository is **UART**, a widely used asynchronous serial communication protocol in embedded and digital systems.

**UART-Protocol-V1 includes:**

* UART Transmitter and Receiver RTL
* Parameterized baud-rate generation
* Parallel-in serial-out and serial-in parallel-out data handling
* Start bit, data bits, stop bit handling
* End-to-end loopback verification
* Constrained-random and directed test scenarios

📁 **Complete implementation, timing analysis, waveforms, and verification details are available in:**
👉 `UART-Protocol-V1/`

---

## Repository Structure

```
Design-Verification-Protocols/
│
├── UART-Protocol-V1/
│   ├── rtl/                # UART Tx and Rx design (SystemVerilog)
│   ├── tb/                 # UVM-like verification environment
│   ├── docs/               # Design explanation, timing analysis
│   └── README.md           # Detailed UART documentation
│
├── LICENSE                 # MIT License
└── README.md               # Repository overview (this file)
```

---

## Verification Methodology

The verification environment follows a **UVM-inspired architecture**, implemented using native SystemVerilog features:

* **Transaction**
  Encapsulates UART data packets.

* **Generator**
  Produces test stimulus and sends transactions to the driver.

* **Driver**
  Drives DUT inputs via a SystemVerilog interface.

* **Monitor**
  Observes DUT outputs and collects received data.

* **Scoreboard**
  Compares expected vs actual data and reports PASS/FAIL.

* **Environment**
  Integrates and synchronizes all verification components.

This structure ensures **modularity, reusability, and scalability**.

---

## Tools & Technologies

* **Language:** SystemVerilog
* **Simulation Tool:** QuestaSim
* **Verification Style:** UVM-like (class-based, mailbox-driven)
* **Design Focus:** Parameterized RTL, protocol accuracy
* **Target Audience:** ASIC / FPGA design and verification roles

---

## Future Work

Planned extensions include:

* Additional communication protocols (SPI, I2C, AXI-lite, etc.)
* Reusable verification components across protocols
* Coverage-driven verification
* Assertions and protocol checkers
* Performance and corner-case testing

---

## License

This project is licensed under the **MIT License**.
See the `LICENSE` file for details.

---

## Author & Contributors

Developed as part of an academic and portfolio-driven effort to simulate **real-world design and verification workflows**.

Contributions, suggestions, and feedback are welcome.

---
