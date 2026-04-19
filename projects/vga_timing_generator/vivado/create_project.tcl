# Minimal Vivado recreate script for vga_timing_generator

# Script location:
#   projects/vga_timing_generator/vivado/create_project.tcl
#
# This script assumes it is executed from its saved location and reconstructs
# a minimal Vivado project from the repository sources.

set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir ..]]
set repo_root    [file normalize [file join $project_root ../..]]

set project_name "vga_timing_generator"
set project_build_dir [file join $project_root build vivado]
set project_xpr_dir   [file join $project_build_dir $project_name]

# Basys3 FPGA part
set fpga_part "xc7a35tcpg236-1"

puts "Script directory  : $script_dir"
puts "Project root      : $project_root"
puts "Repository root   : $repo_root"
puts "Build directory   : $project_build_dir"
puts "Target FPGA part  : $fpga_part"

file mkdir $project_build_dir

create_project $project_name $project_xpr_dir -part $fpga_part -force

# Add source files
add_files -norecurse [file join $project_root pkg vga_timing_pkg.vhd]
add_files -norecurse [file join $project_root rtl core vga_timing_generator.vhd]

# Set top module
set_property top vga_timing_generator [current_fileset]

# Update compile order
update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project file:"
puts "  [get_property directory [current_project]]"
