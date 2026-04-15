#-------------------------------------------------------------------------------------
# U50 double-precision floating-point IP generation script
#
# Generates the floating-point IP blocks expected by Float64.bsv:
#   fp_add64, fp_sub64, fp_mult64, fp_div64, fp_sqrt64, fp_fma64, fp_exp64
#
# Target part:
#   xcu50-fsvh2104-2-e
#
# Output directory:
#   ./u50
#
# Notes:
# - This script writes the 64-bit cores into the same ./u50 directory used by
#   synth-fp-u50.tcl so that fp_import.tcl can import both fp_*32 and fp_*64
#   cores from one place.
# - Existing non-64-bit core subdirectories under ./u50 are left intact.
# - The chosen latencies are intended to match the U50-oriented Float64.bsv
#   wrapper defaults:
#       add/sub = 15
#       mult    = 16
#       div     = 57
#       sqrt    = 57
#       fma     = 29
#       exp     = 33
#-------------------------------------------------------------------------------------

set PART   xcu50-fsvh2104-2-e
set OUTDIR ./u50

file mkdir $OUTDIR

if {[llength [get_projects -quiet]] == 0} {
    create_project -in_memory local_synthesized_ip -part $PART
} else {
    set_property part $PART [current_project]
}

# Try several property dictionaries in order. This is useful because some
# Vivado releases accept slightly different strings for the same option.
proc try_set_property_dicts {ip_name dict_list_list} {
    set ip_obj [get_ips $ip_name]
    set last_err ""

    foreach d $dict_list_list {
        if {![catch {set_property -dict $d $ip_obj} err]} {
            return
        }
        set last_err $err
    }

    error "Failed to configure $ip_name.\nLast error: $last_err"
}

proc genFPCore {corename property_candidates} {
    global OUTDIR

    # Remove only the directory for the target core being regenerated.
    if {[file exists "$OUTDIR/$corename"]} {
        file delete -force "$OUTDIR/$corename"
    }

    create_ip -name floating_point -version 7.1 -vendor xilinx.com -library ip \
        -module_name $corename -dir $OUTDIR

    try_set_property_dicts $corename $property_candidates

    set xci [get_files "$OUTDIR/$corename/$corename.xci"]
    generate_target {instantiation_template} $xci
    generate_target all $xci
    create_ip_run $xci
    generate_target {Synthesis} $xci
    read_ip $xci
    synth_ip [get_ips $corename]
}

# Common property fragments for IEEE-754 double precision (binary64)
set FP64_COMMON [list \
    CONFIG.A_Precision_Type {Double} \
    CONFIG.C_A_Exponent_Width {11} \
    CONFIG.C_A_Fraction_Width {53} \
    CONFIG.C_Result_Exponent_Width {11} \
    CONFIG.C_Result_Fraction_Width {53} \
    CONFIG.Result_Precision_Type {Double} \
    CONFIG.C_Rate {1} \
    CONFIG.Flow_Control {Blocking} \
    CONFIG.Has_RESULT_TREADY {true} \
]

# Medium DSP usage mirrors the single-precision U50 flow used in this repo.
set FP64_MEDDSP [concat $FP64_COMMON [list CONFIG.C_Mult_Usage {Medium_Usage}]]

# fp_add64 : double-precision adder
# The old VC707-oriented Float64.bsv used latency 15 for add/sub. We keep the
# same latency as the U50 starting point.
genFPCore "fp_add64" [list \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Add_Subtract} \
        CONFIG.Add_Sub_Value {Add} \
        CONFIG.C_Latency {15} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Add/Subtract} \
        CONFIG.Add_Sub_Value {Add} \
        CONFIG.C_Latency {15} \
    ]] \
]

# fp_sub64 : double-precision subtractor
# Uses the same latency as fp_add64 because the datapath class is the same.
genFPCore "fp_sub64" [list \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Add_Subtract} \
        CONFIG.Add_Sub_Value {Subtract} \
        CONFIG.C_Latency {15} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Add/Subtract} \
        CONFIG.Add_Sub_Value {Subtract} \
        CONFIG.C_Latency {15} \
    ]] \
]

# fp_mult64 : double-precision multiplier
# The old Float64 reference used latency 16.
genFPCore "fp_mult64" [list \
    [concat $FP64_MEDDSP [list \
        CONFIG.Operation_Type {Multiply} \
        CONFIG.C_Latency {16} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Multiply} \
        CONFIG.C_Latency {16} \
    ]] \
]

# fp_div64 : double-precision divider
# For binary64, fraction width is 53. A natural U50 starting point is 53 + 4 = 57.
genFPCore "fp_div64" [list \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Divide} \
        CONFIG.C_Latency {57} \
    ]] \
]

# fp_sqrt64 : double-precision square root
# Uses the same latency rationale as divide.
genFPCore "fp_sqrt64" [list \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Square_Root} \
        CONFIG.C_Latency {57} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Square_root} \
        CONFIG.C_Latency {57} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Square Root} \
        CONFIG.C_Latency {57} \
    ]] \
]

# fp_fma64 : double-precision fused multiply-add/subtract
# This is a U50-oriented initial latency choice meant to pair with Float64.bsv.
genFPCore "fp_fma64" [list \
    [concat $FP64_MEDDSP [list \
        CONFIG.Operation_Type {FMA} \
        CONFIG.Add_Sub_Value {Both} \
        CONFIG.C_Latency {29} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {FMA} \
        CONFIG.Add_Sub_Value {Both} \
        CONFIG.C_Latency {29} \
    ]] \
]

# fp_exp64 : double-precision exponential
# This is also an initial U50-oriented latency choice meant to pair with Float64.bsv.
genFPCore "fp_exp64" [list \
    [concat $FP64_MEDDSP [list \
        CONFIG.Operation_Type {Exponential} \
        CONFIG.C_Latency {33} \
    ]] \
    [concat $FP64_COMMON [list \
        CONFIG.Operation_Type {Exponential} \
        CONFIG.C_Latency {33} \
    ]] \
]

puts "Generated double-precision floating-point IP under $OUTDIR"
puts "Remember to import the .xci files during XO packaging, e.g. via fp_import.tcl"
