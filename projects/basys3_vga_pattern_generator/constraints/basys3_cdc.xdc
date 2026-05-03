## CDC constraints for wrapper-local request/acknowledge bus handshakes.
##
## The data bus in cdc_bus_handshake is held stable in the source domain until
## the destination domain observes the request toggle and returns the ack
## toggle. These paths are intentionally asynchronous and are validated with
## report_cdc rather than single-clock timing closure.

set_false_path -from [get_ports btnc_i] \
    -to [get_cells -hier -filter {NAME =~ u_reset_controller/btn_meta_s_reg}]
set_false_path -from [get_ports uart_rx_i] \
    -to [get_cells -hier -filter {NAME =~ u_vga_uart_control/u_uart_rx/rx_meta_s_reg}]
set_false_path -to [get_cells -hier -filter {NAME =~ u_reset_controller/sys_rst_pixel_meta_s_reg}]
set_false_path -to [get_cells -hier -filter {NAME =~ u_reset_controller/locked_pixel_meta_s_reg}]

set_false_path -to [get_cells -hier -filter {NAME =~ u_pattern_sel_cdc/dst_req_meta_s_reg}]
set_false_path -to [get_cells -hier -filter {NAME =~ u_pattern_sel_cdc/src_ack_meta_s_reg}]
set_false_path \
    -from [get_cells -hier -filter {NAME =~ u_pattern_sel_cdc/src_data_hold_s_reg*}] \
    -to [get_cells -hier -filter {NAME =~ u_pattern_sel_cdc/dst_data_s_reg*}]

## Runtime VGA mode switch toggle CDC.
##
## requested_mode_s is latched in the system domain before request_toggle_s is
## changed, and is held stable until the switch completes. The pixel domain only
## consumes that payload after observing the synchronized release toggle.
set_false_path -to [get_cells -hier -filter {NAME =~ u_mode_switch_controller/request_meta_s_reg}]
set_false_path -to [get_cells -hier -filter {NAME =~ u_mode_switch_controller/release_meta_s_reg}]
set_false_path -to [get_cells -hier -filter {NAME =~ u_mode_switch_controller/safe_ack_meta_s_reg}]
set_false_path \
    -from [get_cells -hier -filter {NAME =~ u_mode_switch_controller/requested_mode_s_reg*}] \
    -to [get_cells -hier -filter {NAME =~ u_mode_switch_controller/active_mode_s_reg*}]

## The clock mux select lines are changed by the system-domain controller only
## after the pixel domain has acknowledged a frame-safe hold. The mux primitive
## select setup checks are therefore covered by the mode-switch protocol rather
## than normal data-path timing.
set_false_path \
    -to [get_pins -quiet {u_pixel_clk_mux_low/S0 u_pixel_clk_mux_low/S1 u_pixel_clk_mux_top/S0 u_pixel_clk_mux_top/S1}]

## active_mode_s only changes while the pixel pipeline is held/blanked. The
## visible RGB output registers do not consume a mode transition as a same-cycle
## video sample; mode-dependent combinational pattern paths settle while the
## pipeline is blank before visible pixels resume.
set_false_path \
    -from [get_cells -hier -filter {NAME =~ u_mode_switch_controller/active_mode_s_reg*}] \
    -to [get_cells -hier -filter {NAME =~ red_reg_s_reg*}]
set_false_path \
    -from [get_cells -hier -filter {NAME =~ u_mode_switch_controller/active_mode_s_reg*}] \
    -to [get_cells -hier -filter {NAME =~ green_reg_s_reg*}]
set_false_path \
    -from [get_cells -hier -filter {NAME =~ u_mode_switch_controller/active_mode_s_reg*}] \
    -to [get_cells -hier -filter {NAME =~ blue_reg_s_reg*}]
