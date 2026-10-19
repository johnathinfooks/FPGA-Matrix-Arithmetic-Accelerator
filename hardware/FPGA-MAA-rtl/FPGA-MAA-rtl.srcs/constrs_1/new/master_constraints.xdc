
# 100 MHz clock signal
set_property PACKAGE_PIN W5 [get_ports clock]
set_property IOSTANDARD LVCMOS33 [get_ports clock]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clock]

# Reset button (middle of the 5 part)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# uart rx and tx pins
set_property PACKAGE_PIN A18 [get_ports uart_tx_o]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx_o]

set_property PACKAGE_PIN B18 [get_ports uart_rx_i]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_i]