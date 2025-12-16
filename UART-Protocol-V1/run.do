vlib work
vdel -all
vlib work

vlog inf_uart.sv
vlog uart_tx.sv +acc
vlog uart_rx.sv +acc
vlog uart_tb.sv +acc

vsim work.tb_uart
add wave -r *
run -all
