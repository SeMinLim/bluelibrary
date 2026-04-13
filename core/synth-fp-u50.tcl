#-------------------------------------------------------------------------------------
# U50 single-precision floating-point IP generation script
#
# Generates the floating-point IP blocks expected by Float32.bsv:
#   fp_add32, fp_sub32, fp_mult32, fp_div32, fp_sqrt32, fp_fma32, fp_exp32
#
# Output directory:
#   ./u50/<core_name>/<core_name>.xci
#-------------------------------------------------------------------------------------
set PART  xcu50-fsvh2104-2-e
set OUTDIR ./u50
file mkdir $OUTDIR


if {[llength [get_projects -quiet]] == 0} {
	create_project -in_memory local_synthesized_ip -part $PART
} else {
	set_property part $PART [current_project]
}


proc try_set_property_dicts {ip_name dict_list_list} {
	set ip_obj [get_ips $ip_name]
	set last_err ""
	foreach d $dict_list_list {
		if {![catch {set_property -dict $d $ip_obj} err]} {
			return
		}
		set last_err $err
	}
	error "Failed to configure $ip_name. Last error: $last_err"
}


proc genFPCore {corename property_candidates} {
	global OUTDIR

	# Clean previously generated output directory for this core.
	if {[file exists "$OUTDIR/$corename"]} {
		file delete -force "$OUTDIR/$corename"
	}

	# Create the IP instance.
	create_ip -name floating_point -version 7.1 -vendor xilinx.com -library ip \
		  -module_name $corename -dir $OUTDIR
	
	try_set_property_dicts $corename $property_candidates

	# Generate all IP outputs and a synthesis checkpoint.
	set xci [get_files "$OUTDIR/$corename/$corename.xci"]
	generate_target {instantiation_template} $xci
	generate_target all $xci
	create_ip_run $xci
	generate_target {Synthesis} $xci
	read_ip $xci
	synth_ip [get_ips $corename]
}


# Common property fragments
set FP32_COMMON [list \
	CONFIG.A_Precision_Type {Single} \
	CONFIG.C_A_Exponent_Width {8} \
	CONFIG.C_A_Fraction_Width {24} \
	CONFIG.C_Result_Exponent_Width {8} \
	CONFIG.C_Result_Fraction_Width {24} \
	CONFIG.Result_Precision_Type {Single} \
	CONFIG.C_Rate {1} \
	CONFIG.Flow_Control {Blocking} \
	CONFIG.Has_RESULT_TREADY {true} \
]
set FP32_MEDDSP [concat $FP32_COMMON [list CONFIG.C_Mult_Usage {Medium_Usage}]]
# fp_add32 : single-precision adder
genFPCore "fp_add32" [list \
	[list \
		CONFIG.Operation_Type {Add_Subtract} \
		CONFIG.Add_Sub_Value {Add} \
		CONFIG.C_Latency {12} \
		CONFIG.C_Mult_Usage {Medium_Usage} \
		CONFIG.Flow_Control {Blocking} \
		CONFIG.Has_RESULT_TREADY {true} \
	] \
	[list \
		CONFIG.Operation_Type {Add/Subtract} \
		CONFIG.Add_Sub_Value {Add} \
		CONFIG.C_Latency {12} \
		CONFIG.Flow_Control {Blocking} \
		CONFIG.Has_RESULT_TREADY {true} \
	] \
]
# fp_sub32 : single-precision subtractor
genFPCore "fp_sub32" [list \
	[list \
		CONFIG.Operation_Type {Add_Subtract} \
		CONFIG.Add_Sub_Value {Subtract} \
		CONFIG.C_Latency {12} \
		CONFIG.C_Mult_Usage {Medium_Usage} \
		CONFIG.Flow_Control {Blocking} \
		CONFIG.Has_RESULT_TREADY {true} \
	] \
	[list \
		CONFIG.Operation_Type {Add/Subtract} \
		CONFIG.Add_Sub_Value {Subtract} \
		CONFIG.C_Latency {12} \
		CONFIG.Flow_Control {Blocking} \
		CONFIG.Has_RESULT_TREADY {true} \
	] \
]
# fp_mult32 : single-precision multiplier
genFPCore "fp_mult32" [list \
	[concat $FP32_MEDDSP [list \
		CONFIG.Operation_Type {Multiply} \
		CONFIG.C_Latency {7} \
		]
	] \
]
# fp_div32 : single-precision divider
genFPCore "fp_div32" [list \
	[concat $FP32_COMMON [list \
		CONFIG.Operation_Type {Divide} \
		CONFIG.C_Latency {28} \
		]
	] \
]
# fp_sqrt32 : single-precision square root
genFPCore "fp_sqrt32" [list \
	[concat $FP32_COMMON [list \
		CONFIG.Operation_Type {Square_Root} \
		CONFIG.C_Latency {28} \
		]
	] \
	[concat $FP32_COMMON [list \
		CONFIG.Operation_Type {Square_root} \
		CONFIG.C_Latency {28} \
		]
	] \
	[concat $FP32_COMMON [list \
		CONFIG.Operation_Type {Square Root} \
		CONFIG.C_Latency {28} \
		]
	] \
]
# fp_fma32 : single-precision fused multiply-add/subtract
genFPCore "fp_fma32" [list \
	[concat $FP32_MEDDSP [list \
		CONFIG.Add_Sub_Value {Both} \
		CONFIG.C_Latency {17} \
		CONFIG.Operation_Type {FMA} \
		]
	] \
]
# fp_exp32 : single-precision exponential
genFPCore "fp_exp32" [list \
	[concat $FP32_MEDDSP [list \
		CONFIG.Operation_Type {Exponential} \
		CONFIG.C_Latency {21} \
		]
	] \
]

puts "Generated floating-point IP under $OUTDIR"
puts "Remember to import the .xci files during XO packaging, e.g. via fp_import.tcl"
