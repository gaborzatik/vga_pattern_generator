proc sim_require_file {path} {
    set normalized [file normalize $path]

    if {![file exists $normalized]} {
        error "Required simulation file not found: $normalized"
    }

    return $normalized
}

proc sim_ensure_project {script_dir project_file} {
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

proc sim_add_vhdl2008_files {fileset_name file_list} {
    foreach sim_file $file_list {
        set normalized [sim_require_file $sim_file]
        set existing_file [get_files -quiet $normalized]

        if {[llength $existing_file] == 0} {
            add_files -fileset $fileset_name -norecurse $normalized
            set existing_file [get_files $normalized]
        }

        set_property used_in_simulation true $existing_file
        set_property file_type {VHDL 2008} $existing_file
    }
}

proc sim_prepare_fileset {fileset_name top_module file_list} {
    set fileset_obj [get_filesets $fileset_name]

    sim_add_vhdl2008_files $fileset_name $file_list

    update_compile_order -fileset sources_1
    update_compile_order -fileset $fileset_name

    set_property source_set sources_1 $fileset_obj
    set_property top $top_module $fileset_obj
    set_property top_lib xil_defaultlib $fileset_obj
}

proc sim_run_fileset {fileset_name} {
    set fileset_obj [get_filesets $fileset_name]

    set_property xsim.simulate.runtime all $fileset_obj

    launch_simulation -simset $fileset_name -mode behavioral
    run all
    close_sim
}
