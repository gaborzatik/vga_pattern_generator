## Clock
set_property PACKAGE_PIN W5 [get_ports clk_100mhz_i]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz_i]
create_clock -period 10.000 -name clk_100mhz_i [get_ports clk_100mhz_i]

## Runtime pixel clocks from the three-output Clocking Wizard and the
## dedicated two-stage BUFGMUX_CTRL tree are intentionally left for Vivado to
## derive from the Clocking Wizard/MMCM and clock mux primitives. The three
## MMCM output clocks feed a dedicated clock mux tree, so only one runtime pixel
## clock is active in the pixel pipeline at a time.
set_clock_groups -logically_exclusive \
    -group [get_clocks -quiet pixel_clk_vga_s] \
    -group [get_clocks -quiet pixel_clk_svga_s] \
    -group [get_clocks -quiet pixel_clk_xga_s]

## Button
set_property PACKAGE_PIN U18 [get_ports btnc_i]
set_property IOSTANDARD LVCMOS33 [get_ports btnc_i]

## USB-RS232 receive path from the host PC to the FPGA
set_property PACKAGE_PIN B18 [get_ports uart_rx_i]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx_i]

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
