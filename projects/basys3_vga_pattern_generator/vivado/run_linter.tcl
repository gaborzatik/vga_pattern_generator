# Vivado batch script to run RTL lint on the Basys3 VGA pattern generator
# project. If the project does not exist yet, it is recreated first.

set script_dir     [file normalize [file dirname [info script]]]
set project_root   [file normalize [file join $script_dir ..]]
set repo_root      [file normalize [file join $project_root ../..]]
set build_root     [file join $repo_root build]

set project_name   "basys3_vga_pattern_generator"
set fpga_part      "xc7a35tcpg236-1"
set project_dir    [file join $build_root $project_name]
set project_file   [file join $project_dir "${project_name}.xpr"]
set top_module     "basys3_vga_top"
set lint_waiver_script [file join $script_dir lint_waivers.tcl]

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

update_compile_order -fileset sources_1
set_property top $top_module [current_fileset]

if {[file exists $lint_waiver_script]} {
    puts "Loading RTL lint waivers from:"
    puts "  $lint_waiver_script"
    source $lint_waiver_script
}

puts "Running RTL linter for top module:"
puts "  $top_module"
puts "Target part:"
puts "  $fpga_part"

synth_design -top $top_module -part $fpga_part -lint

puts "RTL lint completed."
puts "Primary batch log:"
puts "  vivado.log in the directory from which Vivado was launched"

close_project
