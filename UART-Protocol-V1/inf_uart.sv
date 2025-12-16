interface inf_uart;
  logic clk;
  logic rst;
  logic trans;
  logic [7:0] txdata;
  logic txd;
  logic busy;
  logic [7:0] rxdata;
  logic valid_rx;
endinterface
