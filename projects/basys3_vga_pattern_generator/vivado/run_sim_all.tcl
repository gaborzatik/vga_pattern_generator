# Vivado batch script to run the current Basys3 wrapper simulation suite.

set script_dir     [file normalize [file dirname [info script]]]
set smoke_script   [file join $script_dir run_sim_smoke.tcl]

puts "Running Basys3 wrapper simulation suite:"
puts "  $smoke_script"

source $smoke_script
