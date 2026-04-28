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
