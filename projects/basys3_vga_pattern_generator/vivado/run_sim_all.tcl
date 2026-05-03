# Vivado batch script to run the current Basys3 wrapper simulation suite.

set script_dir     [file normalize [file dirname [info script]]]
set cdc_script     [file join $script_dir run_sim_cdc_bus_handshake.tcl]
set uart_script    [file join $script_dir run_sim_uart_control.tcl]
set mode_script    [file join $script_dir run_sim_mode_switch_controller.tcl]
set smoke_script   [file join $script_dir run_sim_smoke.tcl]

puts "Running Basys3 wrapper simulation suite:"
puts "  $cdc_script"
puts "  $uart_script"
puts "  $mode_script"
puts "  $smoke_script"

source $cdc_script
source $uart_script
source $mode_script
source $smoke_script
