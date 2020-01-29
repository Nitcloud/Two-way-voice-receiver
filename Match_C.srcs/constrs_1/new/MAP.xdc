set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property PACKAGE_PIN K17 [get_ports sys_clk]
create_clock -period 20.000 [get_ports sys_clk]
set_input_jitter [get_clocks -of_objects [get_ports sys_clk]] 0.200
set_property PHASESHIFT_MODE WAVEFORM [get_cells -hierarchical *adv*]

set_property IOSTANDARD LVCMOS33 [get_ports FM_IN]
set_property PACKAGE_PIN G19 [get_ports FM_IN]

set_property IOSTANDARD LVCMOS33 [get_ports LO_OUT]
set_property PACKAGE_PIN J18 [get_ports LO_OUT]

set_property IOSTANDARD LVCMOS33 [get_ports DAC_CH1]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_CH2]
set_property PACKAGE_PIN K19 [get_ports DAC_CH1]
set_property PACKAGE_PIN J20 [get_ports DAC_CH2]



