# Vivado recreate script for basys3_vga_pattern_generator
#
# Repository source root for this subproject:
#   projects/basys3_vga_pattern_generator
#
# Generated Vivado project location:
#   <repo_root>/build/basys3_vga_pattern_generator
#
# This script intentionally recreates the board-specific wrapper project from
# the curated source set currently stored in version control. Shared cores are
# referenced from their own repository locations instead of being copied into
# the wrapper tree.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set timing_root    [file normalize [file join $repo_root projects vga_timing_generator]]
set pattern_root   [file normalize [file join $repo_root projects vga_pattern_core]]

set project_name   "basys3_vga_pattern_generator"
set fpga_part      "xc7a35tcpg236-1"
set clk_wiz_module "clk_wiz_pixel"

set build_root     [file join $repo_root build]
set project_dir    [file join $build_root $project_name]

proc require_file {path} {
    set normalized [file normalize $path]

    if {![file exists $normalized]} {
        error "Required file not found: $normalized"
    }

    return $normalized
}

proc add_source_list {file_list} {
    foreach src_file $file_list {
        add_files -norecurse [require_file $src_file]
    }
}

puts "Script directory  : $script_dir"
puts "Project root      : $project_root"
puts "Repository root   : $repo_root"
puts "Timing core root  : $timing_root"
puts "Pattern core root : $pattern_root"
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

set timing_files [list \
    [file join $timing_root pkg vga_timing_pkg.vhd] \
    [file join $timing_root rtl core vga_timing_generator.vhd] \
]

set pattern_files [list \
    [file join $pattern_root pkg vga_pattern_common_pkg.vhd] \
    [file join $pattern_root pkg vga_pattern_gray_pkg.vhd] \
    [file join $pattern_root rtl pattern pattern_1pixel_border.vhd] \
    [file join $pattern_root rtl pattern pattern_checker.vhd] \
    [file join $pattern_root rtl pattern pattern_grayscale_ramp.vhd] \
    [file join $pattern_root rtl pattern pattern_seven_bars.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_black.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_blue.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_gray_10.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_gray_50.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_gray_80.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_green.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_red.vhd] \
    [file join $pattern_root rtl pattern pattern_solid_white.vhd] \
    [file join $pattern_root rtl core vga_pattern_generator.vhd] \
]

set wrapper_files [list \
    [file join $project_root rtl cdc_bus_handshake.vhd] \
    [file join $project_root rtl reset_controller.vhd] \
    [file join $project_root rtl uart_rx_8n1.vhd] \
    [file join $project_root rtl vga_uart_control.vhd] \
    [file join $project_root rtl vga_mode_switch_controller.vhd] \
    [file join $project_root rtl basys3_vga_top.vhd] \
]

add_source_list $timing_files
add_source_list $pattern_files
add_source_list $wrapper_files

set constraint_file [require_file [file join $project_root constraints basys3_vga.xdc]]
add_files -fileset constrs_1 -norecurse $constraint_file
set cdc_constraint_file [require_file [file join $project_root constraints basys3_cdc.xdc]]
add_files -fileset constrs_1 -norecurse $cdc_constraint_file

# ------------------------------------------------------------------------------
# Clocking Wizard IP
# ------------------------------------------------------------------------------
#
# Directly proven from the checked-in wrapper sources:
#   - module name: clk_wiz_pixel
#   - three generated clock outputs are used (clk_out1/2/3)
#   - input port is clk_in1 driven from the 100 MHz Basys3 board clock
#   - reset input is used and wired to btnc_i
#   - locked output is used to hold the timing core in reset until stable
#
# Current default wrapper mode:
#   - clk_out1 requested output frequency is 25.175 MHz for VGA_640X480_60
#   - clk_out2 requested output frequency is 40.000 MHz for SVGA_800X600_60
#   - clk_out3 requested output frequency is 65.000 MHz for XGA_1024X768_60
#
# The original .xci/.xcix customization file is not present in this workspace,
# so only the parameters evidenced by source plus the necessary reconstruction
# inputs are encoded below.

create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name $clk_wiz_module

set clk_wiz_ip [get_ips $clk_wiz_module]

set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {100.000} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.PRIMARY_PORT {clk_in1} \
    CONFIG.NUM_OUT_CLKS {3} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.175} \
    CONFIG.CLKOUT1_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT1_DRIVES {No_buffer} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {40.000} \
    CONFIG.CLKOUT2_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT2_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT2_DRIVES {No_buffer} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {65.000} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {0.000} \
    CONFIG.CLKOUT3_REQUESTED_DUTY_CYCLE {50.000} \
    CONFIG.CLKOUT3_DRIVES {No_buffer} \
    CONFIG.USE_RESET {true} \
    CONFIG.RESET_PORT {reset} \
    CONFIG.RESET_TYPE {ACTIVE_HIGH} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.LOCKED_PORT {locked} \
] $clk_wiz_ip

set clk_wiz_xci [get_files [file join $project_dir "${project_name}.srcs" sources_1 ip $clk_wiz_module "${clk_wiz_module}.xci"]]

if {[llength $clk_wiz_xci] == 0} {
    error "Clocking Wizard XCI was not created as expected."
}

# Keep the IP synthesized as part of the top-level project flow.
set_property generate_synth_checkpoint false $clk_wiz_xci
generate_target all $clk_wiz_xci

# ------------------------------------------------------------------------------
# Top-level and compile order
# ------------------------------------------------------------------------------

set_property top basys3_vga_top [current_fileset]

update_compile_order -fileset sources_1

puts "Vivado project created successfully."
puts "Project directory:"
puts "  [get_property directory [current_project]]"
puts "Top module:"
puts "  [get_property top [current_fileset]]"
puts "Clocking Wizard IP:"
puts "  $clk_wiz_module"
