set case1 "random_test"
set case2 "add_test"

if [file exists "work"] {vdel -all}
vlib work

if { [file exists "$case1.log"] } {
    file delete "$case1.log"
}

if { [file exists "$case2.log"] } {
    file delete "$case2.log"
}

# Comment out either the SystemVerilog or VHDL DUT.
# There can be only one!

#VHDL DUT
vcom -f dut.f

# SystemVerilog DUT
# vlog ../misc/tinyalu.sv

vlog -f tb.f
vopt top -o top_optimized  +acc +cover=sbfec+tinyalu(rtl).
vsim top_optimized -coverage +UVM_TESTNAME=$case1 +UVM_VERBOSITY=UVM_DEBUG -l $case1.log
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage exclude -src ../../tinyalu_dut/single_cycle_add_and_xor.vhd -line 49 -code s
coverage exclude -src ../../tinyalu_dut/single_cycle_add_and_xor.vhd -scope /top/DUT/add_and_xor -line 49 -code b
coverage save $case1.ucdb


vsim top_optimized -coverage +UVM_TESTNAME=$case2 -l $case2.log
set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all
coverage exclude -src ../../tinyalu_dut/single_cycle_add_and_xor.vhd -line 49 -code s
coverage exclude -src ../../tinyalu_dut/single_cycle_add_and_xor.vhd -scope /top/DUT/add_and_xor -line 49 -code b
coverage save $case2.ucdb

vcover merge  tinyalu.ucdb $case1.ucdb $case2.ucdb
vcover report tinyalu.ucdb -cvg -details
quit

