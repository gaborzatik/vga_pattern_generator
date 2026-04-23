# Vivado batch script to write a bitstream from an already completed impl_1 run.
# If the project does not exist yet, it is recreated first. If impl_1 has not
# completed successfully yet, the script stops and asks the user to run the
# implementation flow first.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]

set project_name   "basys3_vga_pattern_generator"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set runs_dir       [file join $project_dir "${project_name}.runs"]
set reports_dir    [file join $project_dir reports]
set bitstream_name "basys3_vga_top.bit"

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

if {[llength [get_runs impl_1 -quiet]] == 0} {
    error "Implementation run impl_1 does not exist. Run run_implementation.tcl first."
}

set impl_run      [get_runs impl_1]
set impl_progress [get_property PROGRESS $impl_run]
set impl_status   [get_property STATUS $impl_run]

puts "Existing implementation progress:"
puts "  $impl_progress"
puts "Existing implementation status:"
puts "  $impl_status"

if {$impl_progress ne "100%"} {
    error "Implementation run impl_1 is incomplete. Run run_implementation.tcl first."
}

open_run impl_1 -name impl_1

file mkdir $reports_dir

report_timing_summary \
    -delay_type max \
    -max_paths 20 \
    -file [file join $reports_dir impl_timing_summary_recheck.rpt]

write_bitstream -force $bitstream_name

puts "Bitstream written successfully."
puts "Bitstream:"
puts "  [file join $runs_dir impl_1 $bitstream_name]"
puts "Timing recheck report:"
puts "  [file join $reports_dir impl_timing_summary_recheck.rpt]"

close_project
