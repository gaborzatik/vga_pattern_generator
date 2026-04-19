## Clock
set_property PACKAGE_PIN W5 [get_ports clk_100mhz_i]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz_i]

## Button
set_property PACKAGE_PIN U18 [get_ports btnc_i]
set_property IOSTANDARD LVCMOS33 [get_ports btnc_i]

## Switches
set_property PACKAGE_PIN V17 [get_ports {sw_i[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[0]}]

set_property PACKAGE_PIN V16 [get_ports {sw_i[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[1]}]

set_property PACKAGE_PIN W16 [get_ports {sw_i[2]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[2]}]
	
set_property PACKAGE_PIN W17 [get_ports {sw_i[3]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[3]}]
	
set_property PACKAGE_PIN W15 [get_ports {sw_i[4]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[4]}]
	
set_property PACKAGE_PIN V15 [get_ports {sw_i[5]}]					
	set_property IOSTANDARD LVCMOS33 [get_ports {sw_i[5]}]
	
## VGA Red
set_property PACKAGE_PIN G19 [get_ports {vga_red_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_o[0]}]

set_property PACKAGE_PIN H19 [get_ports {vga_red_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_o[1]}]

set_property PACKAGE_PIN J19 [get_ports {vga_red_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_o[2]}]

set_property PACKAGE_PIN N19 [get_ports {vga_red_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red_o[3]}]

## VGA Green
set_property PACKAGE_PIN J17 [get_ports {vga_green_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_o[0]}]

set_property PACKAGE_PIN H17 [get_ports {vga_green_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_o[1]}]

set_property PACKAGE_PIN G17 [get_ports {vga_green_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_o[2]}]

set_property PACKAGE_PIN D17 [get_ports {vga_green_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green_o[3]}]

## VGA Blue
set_property PACKAGE_PIN N18 [get_ports {vga_blue_o[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_o[0]}]

set_property PACKAGE_PIN L18 [get_ports {vga_blue_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_o[1]}]

set_property PACKAGE_PIN K18 [get_ports {vga_blue_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_o[2]}]

set_property PACKAGE_PIN J18 [get_ports {vga_blue_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue_o[3]}]

## VGA Sync
set_property PACKAGE_PIN P19 [get_ports vga_hsync_o]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync_o]

set_property PACKAGE_PIN R19 [get_ports vga_vsync_o]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync_o]

## Configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
