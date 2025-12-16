/////////////////////////////////////////////////////////////////////////////////////////
// Institute      : Portland State University
// Course         : ECE571 Introduction to SystemVerilog
// Instructor     : Venkatesh Patil, Asst. Prof of Practice, ECE, PSU
//
// Team           : Final_Project_Team-11
// Engineer       : Hussien Khodor, Steeva Murikipudi, Venkata Sriram Kamarajugadda 
//
// Design Name    : UART Receiver
// Module Name    : uart_rx
// Project Name   : SystemVerilog-based Design and Verification of UART Tx & Rx
// Simulation Tool: QuestaSim
//
// Description:
// This module implements an 8-bit UART Receiver in SystemVerilog.
// It performs 16x oversampling to reliably detect asynchronous serial data.
// Incoming serial bits are sampled at precise intervals to reconstruct:
//    - Start bit (0)
//    - 8 data bits (LSB first)
//    - Stop bit (1)
// The receiver FSM transitions through IDLE and RECEIVE states, while 
// counters track sampling points and bit boundaries.
//
// Key Functions:
//   - Detect falling edge start bit
//   - Mid-bit sampling for accurate data capture
//   - 16x sample counter for baud synchronization
//   - Bit counter for reconstructing the 10-bit UART frame
//   - Shift register to assemble received byte
//   - valid_rx flag asserted for one cycle when a full byte is received
//
// Additional Comments:
// Designed as part of a complete SystemVerilog UART TX/RX system,
// verified using a structured UVM-like testbench architecture.
//////////////////////////////////////////////////////////////////////////////////////////

module uart_rx (inf_uart uart);

//UART Receiver Parameters
parameter int clk_fq      = 50000000; // System clock frequency: 50 MHz
parameter int baud_rate   = 115200; // UART baud rate (Rx must match Tx)
parameter int div_sample  = 16; // Oversampling factor (16x standard)
parameter int div_cnt     = clk_fq /(baud_rate * div_sample); //No. of clock cycles per sample tick 
parameter int mid_sample  = div_sample / 2; // Mid-bit sample point (8th sample)
parameter int total_bits  = 10; // 1 start + 8 data + 1 stop

// Internal Signals
logic state, nextstate;  // FSM state
logic shift;  // When high → sample bit into shift reg
logic [3:0] bit_cnt; // Counts received bits (0 to 9)
logic [3:0] sample_cnt; // 0 to 15 oversample counter
logic [4:0] cycle_cnt; // Counts clk cycles to generate sample tick
logic [9:0] rx_shiftreg;  // Shift register for 10-bit UART frame
logic clear_bcnt, inc_bcnt; // Bit counter control signals
logic clear_scnt, inc_scnt; // Sample counter control signals
logic valid_rx_next; // Generate valid_rx pulse

// UART Receiver Sequential Logic
always_ff @(posedge uart.clk or posedge uart.rst) begin
    if (uart.rst) begin
        // Reset all state and counters
        state <= 0;
        bit_cnt <= 0;
        sample_cnt <= 0;
        cycle_cnt <= 0;
        rx_shiftreg <= 10'b1111111111; // Idle = all 1's
        uart.valid_rx <= 0;
    end 
    else begin
        uart.valid_rx <= 0; // Default: no data received this cycle
        // Generate 16x sample tick based on cycle counter
        if (cycle_cnt == div_cnt - 1) begin
            cycle_cnt <= 0;
            state     <= nextstate; // Move FSM to next state
			// Sample and shift data at mid-bit location
            if (shift)
                rx_shiftreg <= {uart.txd, rx_shiftreg[9:1]};
                // Update sample counter
                if (clear_scnt)
                    sample_cnt <= 0;
                if (inc_scnt)
                    sample_cnt <= sample_cnt + 1;
                // Update bit counter
                if (clear_bcnt)
                    bit_cnt <= 0;
                if (inc_bcnt)
                    bit_cnt <= bit_cnt + 1;
                // Mark the received byte valid
                if (valid_rx_next)
                    uart.valid_rx <= 1;
            end 
            else begin
                cycle_cnt <= cycle_cnt + 1; // Keep counting clock cycles
            end
        end
    end

// FSM Combinational Logic
    always_comb begin
        // Default values
        shift = 0;
        clear_scnt = 0;
        inc_scnt = 0;
        clear_bcnt = 0;
        inc_bcnt = 0;
        valid_rx_next = 0;
        nextstate = state;

        case (state)
		// STATE 0: IDLE — Wait for START bit (falling edge)
        0: begin
            if (!uart.txd) begin  // Start bit detected (line goes LOW)
                nextstate   = 1;  // Move to data receiving state
                clear_bcnt  = 1;  // Reset bit counter
                clear_scnt  = 1;  // Reset sample counter
                end
            end
        // STATE 1: RECEIVE — Sample bits at the middle
        1: begin
            // Sample the bit at the mid-point of the bit period
            if (sample_cnt == mid_sample)
                shift = 1;

            // End of oversampling window (16 samples)
            if (sample_cnt == div_sample - 1) begin
                clear_scnt = 1; // Reset sample counter

                if (bit_cnt == total_bits - 1) begin
                    // Last bit received → check STOP bit
                    if (rx_shiftreg[9]) // STOP bit must be HIGH
                        valid_rx_next = 1; // Byte is valid
						nextstate = 0; // Go back to IDLE
                    end
                    else begin
                        inc_bcnt = 1; // Next bit
                    end
                end 
                else begin
                    inc_scnt = 1; // Continue oversampling
                end
            end
        endcase
    end
	// Extract Received Byte (bits D7..D0)
	assign uart.rxdata = rx_shiftreg[8:1];
endmodule

/*module uart_rx (inf_uart uart);

parameter int clk_fq = 50000000;
parameter int baud_rate = 115200;
parameter int div_sample = 16;
parameter int div_cnt = clk_fq / (baud_rate * div_sample);
parameter int mid_sample = div_sample / 2;
parameter int total_bits = 10;

logic state, nextstate;
logic shift;
logic [3:0] bit_cnt;
logic [3:0] sample_cnt;
logic [4:0] cycle_cnt;
logic [9:0] rx_shiftreg;
logic clear_bcnt, inc_bcnt;
logic clear_scnt, inc_scnt;
logic valid_rx_next;

always_ff @(posedge uart.clk or posedge uart.rst) begin
    if (uart.rst) begin
      state<=0;
      bit_cnt<=0;
      sample_cnt<=0;
      cycle_cnt<=0;
      rx_shiftreg<=10'b1111111111;
      uart.valid_rx<=0;
    end else begin
      uart.valid_rx<=0;

      if (cycle_cnt == div_cnt - 1) begin
        cycle_cnt <=0;
        state<=nextstate;

        if (shift)
          rx_shiftreg<={uart.txd, rx_shiftreg[9:1]};
        if (clear_scnt)
          sample_cnt<=0;
        if (inc_scnt)
          sample_cnt<=sample_cnt + 1;
        if (clear_bcnt)
          bit_cnt<=0;
        if (inc_bcnt)
          bit_cnt<=bit_cnt + 1;

        if (valid_rx_next)
          uart.valid_rx<=1;
      end else begin
        cycle_cnt<=cycle_cnt + 1;
      end
    end
  end

  always_comb begin
    shift=0;
    clear_scnt=0;
    inc_scnt=0;
    clear_bcnt=0;
    inc_bcnt=0;
    valid_rx_next=0;
    nextstate=state;

    case (state)
      0:begin
        if(!uart.txd) begin
          nextstate=1;
          clear_bcnt=1;
          clear_scnt=1;
        end
      end

      1: begin
        if (sample_cnt == mid_sample)
          shift=1;

        if (sample_cnt == div_sample - 1) begin
          clear_scnt=1;
          if (bit_cnt == total_bits - 1) begin
            if (rx_shiftreg[9])
              valid_rx_next=1;
            nextstate=0;
          end else begin
            inc_bcnt=1;
          end
        end else begin
          inc_scnt=1;
        end
      end
    endcase
  end

  assign uart.rxdata = rx_shiftreg[8:1];

endmodule*/
