# Vivado batch script to run the Basys3 wrapper smoke simulation.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]
set helper_script  [file join $repo_root scripts vivado_sim_helpers.tcl]
set pattern_root   [file normalize [file join $repo_root projects vga_pattern_core]]

set project_name   "basys3_vga_pattern_generator"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set sim_top        "tb_basys3_vga_top_smoke"

set wrapper_design_files [list \
    [file join $project_root rtl cdc_bus_handshake.vhd] \
    [file join $project_root rtl reset_controller.vhd] \
    [file join $project_root rtl uart_rx_8n1.vhd] \
    [file join $project_root rtl vga_uart_control.vhd] \
    [file join $project_root rtl basys3_vga_top.vhd] \
]

set sim_files [list \
    [file join $pattern_root sim pkg vga_pattern_sim_pkg.vhd] \
    [file join $project_root sim model clk_wiz_pixel.vhd] \
    [file join $project_root sim tb tb_basys3_vga_top_smoke.vhd] \
]

source $helper_script

sim_ensure_project $script_dir $project_file

set clk_wiz_ip_files [get_files -quiet *clk_wiz_pixel.xci*]
foreach ip_file $clk_wiz_ip_files {
    set_property used_in_simulation false $ip_file
}

sim_ensure_design_files sources_1 $wrapper_design_files
sim_prepare_fileset sim_1 $sim_top $sim_files

puts "Running simulation top:"
puts "  $sim_top"

set sim_failed 0
set sim_result [catch {sim_run_fileset sim_1} sim_error]

foreach ip_file $clk_wiz_ip_files {
    set_property used_in_simulation true $ip_file
}

if {$sim_result != 0} {
    set sim_failed 1
}

if {$sim_failed} {
    close_project
    error $sim_error
}

puts "Simulation completed successfully:"
puts "  $sim_top"

close_project
