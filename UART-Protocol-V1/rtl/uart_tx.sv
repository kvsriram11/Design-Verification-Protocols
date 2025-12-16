/////////////////////////////////////////////////////////////////////////////////////////
//Institute: Portland State University
//Course: ECE571 Introduction to SystemVerilog
//Instructor: Venkatesh Patil, Asst. Prof of Practice, ECE, PSU
//
//Team: Final_Project_Team-11
//Engineer: Hussien Khodor & Steeva Murikipudi
//
//Design Name: UART Transmitter
//Module Name: uart_tx
//Project Name: SystemVerilog-based Design and Verification of UART Tx & Rx
//Simulation Tool: QuestaSim
//
//Description:
//This module implements an 8-bit UART Transmitter in SystemVerilog.
//The transmitter loads a parallel byte into a 10-bit shift register consisting of: 
//   - 1 start bit (0)
//   - 8 data bits (LSB first)
//   - 1 stop bit (1)
//The module generates baud-rate–timed serial transmission by shifting
//bits out on the txd line. A busy signal is asserted while transmission
//is in progress to prevent new data from being loaded.
//
//Additional Comments:
// Designed as part of a complete SystemVerilog UART TX/RX system
// with a UVM-like verification environment.
//
//////////////////////////////////////////////////////////////////////////////////////////

module uart_tx (inf_uart uart);

// UART Transmitter Parameters
parameter int clk_fq    = 50000000;          // system clock frequency (50 MHz)
parameter int baud_rate = 115200;            // UART baud rate
parameter int div_cnt   = clk_fq / baud_rate; // Number of clock cycles per UART bit


// Internal Registers

logic [8:0] cycle_cnt;      // Counts clock cycles for baud timing
logic [3:0] bit_index;      // Tracks current bit being transmitted (0–9)
logic [9:0] tx_shift;       // 10-bit UART frame {stop, data[7:0], start}
logic sending;              // Transmission active flag


// UART Transmitter Logic
always_ff @(posedge uart.clk or posedge uart.rst) begin

// Asynchronous Reset
   if (uart.rst) begin
    uart.txd   <= 1;  // TX line is idle HIGH
    sending    <= 0;  // No active transmission
    cycle_cnt  <= 0;  // Reset baud counter
    bit_index  <= 0;  // Reset bit index
    uart.busy  <= 0;  // Not currently transmitting
  end 

   else begin
    // Start a New Transmission
   // Condition: transmit signal asserted & transmitter not busy
   if (uart.trans && !sending) begin
      tx_shift  <= {1'b1, uart.txdata, 1'b0}; 
       // Frame format: STOP (1), DATA[7:0], START (0)
		sending    <= 1; // Mark transmission active
		bit_index  <= 0; // Begin with START bit
        cycle_cnt  <= 0; // Reset baud counter
        uart.busy  <= 1; // Indicate transmitter is busy
    end 

    // Transmitting Bits
    else if (sending) begin
      // Check if bit time is completed
      if (cycle_cnt == div_cnt - 1) begin
		cycle_cnt <= 0;  // Reset baud counter
        uart.txd <= tx_shift[bit_index]; // Output current bit (LSB first)
        bit_index <= bit_index + 1;      // Move to next bit

            // Check if all 10 bits are transmitted
            if (bit_index == 9) begin
            sending   <= 0;  // Transmission complete
            uart.txd  <= 1;  // Idle HIGH
            uart.busy <= 0;  // Ready for next data
            end
            end 

            // Counting clock cycles for baud division
            else begin
                cycle_cnt <= cycle_cnt + 1;
            end
        end
    end
end

endmodule

/*module uart_tx (inf_uart uart);

parameter int clk_fq = 50000000;
parameter int baud_rate = 115200;
parameter int div_cnt = clk_fq / baud_rate;

  logic [8:0] cycle_cnt;
  logic [3:0] bit_index;
  logic [9:0] tx_shift;
  logic sending;

  always_ff @(posedge uart.clk or posedge uart.rst) begin
    if (uart.rst) begin
      uart.txd <= 1;
      sending <= 0;
      cycle_cnt <= 0;
      bit_index <= 0;
      uart.busy <= 0;
    end else begin
      if (uart.trans && !sending) begin
        tx_shift <= {1'b1, uart.txdata, 1'b0};
        sending <= 1;
        bit_index <= 0;
        cycle_cnt <= 0;
        uart.busy <= 1;
      end else if (sending) begin
        if (cycle_cnt == div_cnt - 1) begin
          cycle_cnt <= 0;
          uart.txd <= tx_shift[bit_index];
          bit_index <= bit_index + 1;
          if (bit_index == 9) begin
            sending <= 0;
            uart.txd <= 1;
            uart.busy <= 0;
          end
        end else begin
          cycle_cnt <= cycle_cnt + 1;
        end
      end
    end
  end

endmodule*/

