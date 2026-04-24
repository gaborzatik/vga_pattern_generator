# Vivado batch script to run the geometry-focused pattern-generator simulation.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]
set helper_script  [file join $repo_root scripts vivado_sim_helpers.tcl]

set project_name   "vga_pattern_core"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set sim_top        "tb_vga_pattern_generator_geometry"

set sim_files [list \
    [file join $project_root sim pkg vga_pattern_sim_pkg.vhd] \
    [file join $project_root sim tb tb_vga_pattern_generator_geometry.vhd] \
]

source $helper_script

sim_ensure_project $script_dir $project_file
sim_prepare_fileset sim_1 $sim_top $sim_files

puts "Running simulation top:"
puts "  $sim_top"

sim_run_fileset sim_1

puts "Simulation completed successfully:"
puts "  $sim_top"

close_project
