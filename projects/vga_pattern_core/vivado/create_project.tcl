# Vivado recreate script for vga_pattern_core
#
# Repository source root for this subproject:
#   projects/vga_pattern_core
#
# Generated Vivado project location:
#   <repo_root>/build/vga_pattern_core
#
# This script intentionally recreates the project from the curated source set
# currently stored in version control.

set script_dir    [file normalize [file dirname [info script]]]
set project_root  [file normalize [file join $script_dir ..]]
set repo_root     [file normalize [file join $project_root ../..]]
set timing_root   [file normalize [file join $repo_root projects vga_timing_generator]]

set project_name  "vga_pattern_core"
set fpga_part     "xc7a35tcpg236-1"

# Keep generated project files out of the source tree
set build_root    [file join $repo_root build]
set project_dir   [file join $build_root $project_name]

puts "Script directory  : $script_dir"
puts "Project root      : $project_root"
puts "Repository root   : $repo_root"
puts "Timing core root  : $timing_root"
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

# Timing package dependency used by coordinate-aware patterns.
add_files -norecurse [file join $timing_root pkg vga_timing_pkg.vhd]

# Packages
add_files -norecurse [file join $project_root pkg vga_pattern_common_pkg.vhd]
add_files -norecurse [file join $project_root pkg vga_pattern_gray_pkg.vhd]

# Pattern modules
add_files -norecurse [file join $project_root rtl pattern pattern_1pixel_border.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_checker.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_grayscale_ramp.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_seven_bars.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_black.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_blue.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_gray_10.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_gray_50.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_gray_80.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_green.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_red.vhd]
add_files -norecurse [file join $project_root rtl pattern pattern_solid_white.vhd]

# Core module
add_files -norecurse [file join $project_root rtl core vga_pattern_generator.vhd]

# Top module
set_property top vga_pattern_generator [current_fileset]

# Refresh compile order
update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project directory:"
puts "  [get_property directory [current_project]]"
puts "Target language:"
puts "  [get_property target_language [current_project]]"
puts "Simulator language:"
puts "  [get_property simulator_language [current_project]]"
