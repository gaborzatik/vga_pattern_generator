# Vivado batch script to synthesize the Basys3 wrapper and emit a CDC report.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]

set project_name   "basys3_vga_pattern_generator"
set fpga_part      "xc7a35tcpg236-1"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set reports_dir    [file join $project_dir reports]
set top_module     "basys3_vga_top"

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

file mkdir $reports_dir

update_compile_order -fileset sources_1
set_property top $top_module [current_fileset]

puts "Synthesizing design for CDC report:"
puts "  $top_module"

synth_design -top $top_module -part $fpga_part

set cdc_report [file join $reports_dir cdc_report.rpt]

report_cdc \
    -details \
    -file $cdc_report

puts "CDC report written:"
puts "  $cdc_report"

close_project
