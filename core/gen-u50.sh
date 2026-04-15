#!/bin/bash
rm -rf u50

vivado -mode batch -source synth-fp-u50.tcl -nolog -nojournal
vivado -mode batch -source synth-fp-double-u50.tcl -nolog -nojournal
#vivado -mode batch -source synth-cordic-vc707.tcl -nolog -nojournal
#vivado -mode batch -source synth-divisor-vc707.tcl -nolog -nojournal
