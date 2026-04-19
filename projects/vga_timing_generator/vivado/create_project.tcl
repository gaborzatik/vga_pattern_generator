# Minimal Vivado recreate script for vga_timing_generator

# Script location:
#   projects/vga_timing_generator/vivado/create_project.tcl
#
# This script reconstructs a minimal Vivado project from repository sources.
# Generated build content is intentionally placed in a short path under repo_root/build
# to reduce Windows path-length issues.

set script_dir    [file normalize [file dirname [info script]]]
set project_root  [file normalize [file join $script_dir ..]]
set repo_root     [file normalize [file join $project_root ../..]]

set project_name  "vga_timing_generator"
set fpga_part     "xc7a35tcpg236-1"

# Shorter generated project path
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

# Add source files
add_files -norecurse [file join $project_root pkg vga_timing_pkg.vhd]
add_files -norecurse [file join $project_root rtl core vga_timing_generator.vhd]

# Set top module
set_property top vga_timing_generator [current_fileset]

# Refresh compile order
update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project directory:"
puts "  [get_property directory [current_project]]"
