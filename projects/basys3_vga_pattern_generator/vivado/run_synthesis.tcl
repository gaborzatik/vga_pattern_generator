# Vivado batch script to run synthesis for the Basys3 VGA pattern generator
# project. If the project does not exist yet, it is recreated first.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]

set project_name   "basys3_vga_pattern_generator"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set runs_dir       [file join $project_dir "${project_name}.runs"]
set reports_dir    [file join $project_dir reports]
set top_module     "basys3_vga_top"
set launch_jobs    4

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

if {[llength [get_runs impl_1 -quiet]] != 0} {
    reset_run impl_1
}
reset_run synth_1

puts "Launching synthesis run:"
puts "  synth_1"
launch_runs synth_1 -jobs $launch_jobs
wait_on_run synth_1

set synth_run      [get_runs synth_1]
set synth_progress [get_property PROGRESS $synth_run]
set synth_status   [get_property STATUS $synth_run]

puts "Synthesis progress:"
puts "  $synth_progress"
puts "Synthesis status:"
puts "  $synth_status"

if {$synth_progress ne "100%"} {
    error "Synthesis did not complete successfully."
}

open_run synth_1 -name synth_1

report_utilization \
    -file [file join $reports_dir synth_utilization.rpt]
report_timing_summary \
    -delay_type max \
    -max_paths 20 \
    -file [file join $reports_dir synth_timing_summary.rpt]

puts "Synthesis completed successfully."
puts "Run log:"
puts "  [file join $runs_dir synth_1 runme.log]"
puts "Reports:"
puts "  [file join $reports_dir synth_utilization.rpt]"
puts "  [file join $reports_dir synth_timing_summary.rpt]"

close_project
