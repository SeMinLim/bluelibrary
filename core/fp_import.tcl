#-----------------------------------------------------------------------------------------------
# fp_import.tcl
#
# Import pre-generated floating-point Vivado IP cores (.xci) into the currently opened project.
#
# Expected directory layout:
#   <coredir>/fp_add32/fp_add32.xci
#   <coredir>/fp_sub32/fp_sub32.xci
#   <coredir>/fp_mult32/fp_mult32.xci
#   ...
#-----------------------------------------------------------------------------------------------
proc addFpCores {coredir {required_cores {}}} {
	set normdir [file normalize $coredir]

	if {![file exists $normdir]} {
		error "addFpCores: directory does not exist: $normdir"
	}

	if {![file isdirectory $normdir]} {
		error "addFpCores: path is not a directory: $normdir"
	}

	if {[llength $required_cores] > 0} {
		set missing {}
		foreach core $required_cores {
			set xci [file join $normdir $core ${core}.xci]
			if {![file exists $xci]} lappend missing $core
		}
		if {[llength $missing] > 0} {
			error "addFpCores: missing required IP core(s) under $normdir: $missing"
		}
	}

	set ip_files [lsort [glob -nocomplain -types f -directory $normdir */*.xci]]

	if {[llength $ip_files] == 0} {
		error "addFpCores: no .xci files found under $normdir"
	}

	puts "INFO: addFpCores: importing [llength $ip_files] IP core(s) from $normdir"
	
	foreach ip $ip_files {
		set core_name [file tail [file dirname $ip]]
		puts "INFO:   + $core_name"
	}

	# Minimal, packaging-friendly behavior: add the XCI files to the currentproject. 
	# The surrounding package_kernel.tcl can then run update_compile_order before ipx::package_project.
	add_files -norecurse $ip_files

	return $ip_files
}
