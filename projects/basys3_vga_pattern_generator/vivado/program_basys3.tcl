# Vivado batch script to connect to a Basys3 board through Hardware Manager and
# program the FPGA with the generated bitstream.

set script_dir      [file normalize [file dirname [info script]]]
set project_root    [file normalize [file join $script_dir ..]]
set repo_root       [file normalize [file join $project_root ../..]]
set build_root      [file join $repo_root build]

set project_name    "basys3_vga_pattern_generator"
set project_dir     [file join $build_root $project_name]
set project_file    [file join $project_dir "${project_name}.xpr"]
set runs_dir        [file join $project_dir "${project_name}.runs"]
set bitstream_file  [file join $runs_dir impl_1 basys3_vga_top.bit]
set hw_server_url   "localhost:3121"

proc ensure_project {script_dir project_file} {
    if {[file exists $project_file]} {
        puts "Opening existing project:"
        puts "  $project_file"
        open_project $project_file
    } else {
        set create_script [file join $script_dir create_project.tcl]
        puts "Project file not found. Recreating project from:"
        puts "  $create_script"
        source $create_script
    }
}

ensure_project $script_dir $project_file

if {![file exists $bitstream_file]} {
    error "Bitstream not found: $bitstream_file . Run run_implementation.tcl or write_bitstream_only.tcl first."
}

open_hw_manager
connect_hw_server -url $hw_server_url

set hw_targets [get_hw_targets]
if {[llength $hw_targets] == 0} {
    error "No hardware targets found. Check the USB/JTAG connection to the Basys3 board."
}

set selected_target ""
foreach target $hw_targets {
    set target_name [get_property NAME $target]
    if {[string match -nocase "*digilent*" $target_name]} {
        set selected_target $target
        break
    }
}

if {$selected_target eq ""} {
    set selected_target [lindex $hw_targets 0]
}

puts "Opening hardware target:"
puts "  [get_property NAME $selected_target]"

current_hw_target $selected_target
open_hw_target

set hw_devices [get_hw_devices]
if {[llength $hw_devices] == 0} {
    error "No hardware devices found on the opened target."
}

current_hw_device [lindex $hw_devices 0]

refresh_hw_device -update_hw_probes false [current_hw_device]
set_property PROGRAM.FILE $bitstream_file [current_hw_device]
program_hw_devices [current_hw_device]
refresh_hw_device [current_hw_device]

puts "Programming completed."
puts "Bitstream used:"
puts "  $bitstream_file"
puts "Current device:"
puts "  [get_property NAME [current_hw_device]]"
puts "DONE:"
puts "  [get_property REGISTER.IR.BIT5_DONE [current_hw_device]]"

close_project
