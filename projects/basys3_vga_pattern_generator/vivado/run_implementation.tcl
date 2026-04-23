# Vivado batch script to run synthesis and implementation for the Basys3 VGA
# pattern generator project. If the project does not exist yet, it is
# recreated first.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]

set project_name   "basys3_vga_pattern_generator"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set runs_dir       [file join $project_dir "${project_name}.runs"]
set reports_dir    [file join $project_dir reports]
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
set_property top basys3_vga_top [current_fileset]

reset_run impl_1
reset_run synth_1

puts "Launching synthesis prerequisite run:"
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
    error "Implementation script stopped because synthesis did not complete successfully."
}

puts "Launching implementation run:"
puts "  impl_1"
launch_runs impl_1 -to_step write_bitstream -jobs $launch_jobs
wait_on_run impl_1

set impl_run      [get_runs impl_1]
set impl_progress [get_property PROGRESS $impl_run]
set impl_status   [get_property STATUS $impl_run]

puts "Implementation progress:"
puts "  $impl_progress"
puts "Implementation status:"
puts "  $impl_status"

if {$impl_progress ne "100%"} {
    error "Implementation did not complete successfully."
}

open_run impl_1 -name impl_1

report_utilization \
    -file [file join $reports_dir impl_utilization.rpt]
report_timing_summary \
    -delay_type max \
    -max_paths 20 \
    -file [file join $reports_dir impl_timing_summary.rpt]
report_drc \
    -file [file join $reports_dir impl_drc.rpt]
report_power \
    -file [file join $reports_dir impl_power.rpt]

puts "Implementation completed successfully."
puts "Synthesis run log:"
puts "  [file join $runs_dir synth_1 runme.log]"
puts "Implementation run log:"
puts "  [file join $runs_dir impl_1 runme.log]"
puts "Reports:"
puts "  [file join $reports_dir impl_utilization.rpt]"
puts "  [file join $reports_dir impl_timing_summary.rpt]"
puts "  [file join $reports_dir impl_drc.rpt]"
puts "  [file join $reports_dir impl_power.rpt]"

close_project
