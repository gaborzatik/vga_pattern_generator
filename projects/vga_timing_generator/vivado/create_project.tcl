# Vivado recreate script for vga_timing_generator
#
# Repository source root for this subproject:
#   projects/vga_timing_generator
#
# Generated Vivado project location:
#   <repo_root>/build/vga_timing_generator
#
# This script intentionally recreates the project from the curated source set
# currently stored in version control.

set script_dir    [file normalize [file dirname [info script]]]
set project_root  [file normalize [file join $script_dir ..]]
set repo_root     [file normalize [file join $project_root ../..]]

set project_name  "vga_timing_generator"
set fpga_part     "xc7a35tcpg236-1"

# Keep generated project files out of the source tree
set build_root    [file join $repo_root build]
set project_dir   [file join $build_root $project_name]

puts "Script directory  : $script_dir"
puts "Project root      : $project_root"
puts "Repository root   : $repo_root"
puts "Build root        : $build_root"
puts "Project directory : $project_dir"
puts "Target FPGA part  : $fpga_part"

file mkdir $build_root

create_project $project_name $project_dir -part $fpga_part -force

# Project language settings
set_property target_language VHDL [current_project]
set_property simulator_language Mixed [current_project]
set_property default_lib xil_defaultlib [current_project]

# ------------------------------------------------------------------------------
# Design sources
# ------------------------------------------------------------------------------

# Package
add_files -norecurse [file join $project_root pkg vga_timing_pkg.vhd]

# Core module
add_files -norecurse [file join $project_root rtl core vga_timing_generator.vhd]

# Top module
set_property top vga_timing_generator [current_fileset]

# Refresh compile order
update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project directory:"
puts "  [get_property directory [current_project]]"
puts "Target language:"
puts "  [get_property target_language [current_project]]"
puts "Simulator language:"
puts "  [get_property simulator_language [current_project]]"
