/////////////////////////////////////////////////////////////////////////////////////////
// Institute      : Portland State University
// Course         : ECE571 Introduction to SystemVerilog
// Instructor     : Venkatesh Patil, Asst. Prof of Practice, ECE, PSU
//
// Team           : Final_Project_Team-11
// Engineers      : Venkata Sriram Kamarajugadda & Carson Waldron
//
// Design Name    : UART Verification Environment
// File Name      : uart_tb.sv
// Project Name   : SystemVerilog-based Design and Verification of UART Tx & Rx
// Simulation Tool: QuestaSim
//
// Description:
// This SystemVerilog file implements a complete UVM-like verification 
// environment for the UART Transmitter and Receiver modules. It includes:
//     - Interface   : Defines all UART DUT signals
//     - Transaction : Encapsulates 8-bit data items for stimulus and checking
//     - Generator   : Produces a sequence of UART transactions
//     - Driver      : Drives transactions onto the UART interface
//     - Monitor     : Observes DUT outputs and forwards received data
//     - Scoreboard  : Compares DUT output with expected results
//     - Environment : Connects all verification components using mailboxes
//     - Testbench   : Instantiates DUT, environment, clock, and reset logic
//
// Key Features:
//   - Message-based stimulus generation ("PORTLAND STATE UNIVERSITY")
//   - Self-checking scoreboard for data-by-data comparison
//   - Transaction-level abstraction for reusable stimulus
//   - Mailbox-based communication between generator, driver, monitor, and scoreboard
//   - Clear separation between Testbench and RTL design (no direct DUT access)
//
// Additional Comments:
// This testbench was designed collaboratively by the verification team,
// following industry-style constrained modular verification methodology.
// It structurally resembles a simplified UVM environment.
//////////////////////////////////////////////////////////////////////////////////////////

// UART Interface: Bundles all DUT signals into one connection
interface inf_uart;
  logic clk; // System clock
  logic rst; // Synchronous active-high reset
  logic trans; // Transmit request signal (1-cycle pulse)
  logic [7:0] txdata; // Parallel TX data input
  logic txd; // Serial TX output line
  logic busy; // Indicates TX is currently sending a frame
  logic [7:0] rxdata; // Parallel RX output data
  logic valid_rx; // Asserted for 1 cycle when a byte is received
endinterface



// uart_transaction:
// Holds one packet of data used by driver & monitor.
class uart_transaction;
  rand bit [7:0] data; // Randomized/specified TX byte
  bit  [7:0] received_data; // Byte captured by RX

// Utility: print transaction contents
  function void display(string tag);
    $display("[%s] Data: %s (%0h)", tag, data, data);
  endfunction
endclass

// generator:
// Produces a sequence of transactions and sends them to driver.
// Here we transmit: "PORTLAND STATE UNIVERSITY"
class generator;
  mailbox gen2drv; // Mailbox for sending transactions to driver
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task run();
    uart_transaction tr;
	// Message encoded as ASCII bytes
    byte message[25] = {"P", "O", "R", "T", "L", "A","N", "D"," ","S", "T", "A", "T","E"," ","U", "N", "I", "V", "E","R", "S", "I", "T", "Y"};
	// Loop through message and create transactions
    for (int i = 0; i < $size(message); i++) begin
      tr = new();
      tr.data = message[i];
      tr.display("GEN");
      gen2drv.put(tr);// Send to driver
      #1000;// Space out transactions
    end
  endtask
endclass

// driver:
// Receives transactions from generator and drives DUT TX ports.
// Handles UART busy handshake.
class driver;
  virtual inf_uart uart;
  mailbox gen2drv;

  function new(virtual inf_uart uart, mailbox gen2drv);
    this.uart = uart;
    this.gen2drv = gen2drv;
  endfunction

  task run();
    uart_transaction tr;

    repeat (25) begin
      gen2drv.get(tr); // Get next byte from generator

      @(negedge uart.clk); // Clean clock edge

      // Wait while transmitter is busy
      while (uart.busy)
        @(negedge uart.clk);

      // Apply data to DUT
      uart.txdata = tr.data;
      uart.trans  = 1; // Pulse transmit request
	  
      @(negedge uart.clk);
      uart.trans = 0;
    end
  endtask
endclass

// monitor:
// Observes RX output and captures bytes when valid_rx pulses.
// Sends received transactions to scoreboard.
class monitor;
  virtual inf_uart uart;
  mailbox mon2scb;

  function new(virtual inf_uart uart, mailbox mon2scb);
    this.uart = uart;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    int count = 0;

    // RX should output exactly 25 bytes
    while (count < 25) begin
      @(posedge uart.clk);

      if (uart.valid_rx) begin
        uart_transaction tr = new();
        tr.received_data = uart.rxdata;

        $display("[MON] Received: %s (%0h)", tr.received_data, tr.received_data);
        mon2scb.put(tr);  // Send to scoreboard
        count++;
      end
    end
  endtask
endclass


// scoreboard:
// Compares received bytes with expected “PORTLAND STATE UNIVERSITY”
// and prints PASS/FAIL for each.
class scoreboard;
  mailbox mon2scb;

  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  task run();
    uart_transaction tr;
    byte expected[25] = {"P", "O", "R", "T", "L", "A","N", "D"," ","S", "T", "A", "T","E"," ","U", "N", "I", "V", "E","R", "S", "I", "T", "Y"};
    for (int i = 0; i < $size(expected); i++) begin
      mon2scb.get(tr); // Get received byte
      if (tr.received_data !== expected[i])
        $display("[SCB][FAIL] Expected %s, Got %s", expected[i], tr.received_data);
      else
        $display("[SCB][PASS] Received %s", tr.received_data);
    end
  endtask
endclass

// environment:
// Instantiates generator, driver, monitor, and scoreboard.
// Starts all components in parallel using fork/join.
class environment;
  generator   g;
  driver      d;
  monitor     m;
  scoreboard  s;

  mailbox gen2drv = new();
  mailbox mon2scb = new();

  virtual inf_uart uart;

  function new(virtual inf_uart uart);
    this.uart = uart;
    g = new(gen2drv);
    d = new(uart, gen2drv);
    m = new(uart, mon2scb);
    s = new(mon2scb);
  endfunction

  task run();
    fork
      g.run();   // Produce transactions
      d.run();   // Drive DUT
      m.run();   // Monitor RX output
      s.run();   // Check results
    join
  endtask
endclass

// uart_instans:
// Instantiates UART TX and RX modules and connects them through
// the shared interface.

module uart_instans (inf_uart uart);
  uart_tx tx_inst (uart);
  uart_rx rx_inst (uart);
endmodule

// tb_uart:
// Top-level testbench.
// Generates clock, reset, and starts environment.
module tb_uart;
  inf_uart uart();           // Create interface instance
  uart_instans dut (.uart(uart));  // Connect DUT

  // Clock Generation (50 MHz)
  initial uart.clk = 0;
  always #10 uart.clk = ~uart.clk;

  environment env;

  initial begin
     // Initialize interface
     uart.rst    = 1;
     uart.trans  = 0;
     uart.txdata = 0;

     #100;
     uart.rst = 0;
     #100;

     // Start environment
     env = new(uart);
     env.run();

     $display("[TB] Simulation completed.");
     $finish;
  end
endmodule
