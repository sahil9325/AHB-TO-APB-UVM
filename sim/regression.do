cd ~/majorproj

# ============================================================
# AHB-to-APB BRIDGE UVM REGRESSION
# Questa / ModelSim
# ============================================================

set ROOT /home/sahil/majorproj
set UVM  /home/sahil/questa/questa_fse/verilog_src/uvm-1.1d/src

set TOTAL_TESTS 6
set PASS_COUNT 0
set FAIL_COUNT 0

proc print_test_result {num name result} {
    global PASS_COUNT FAIL_COUNT

    if {$result == "PASS"} {
        incr PASS_COUNT
        puts [format "TEST %-2s %-30s : PASS" $num $name]
    } else {
        incr FAIL_COUNT
        puts [format "TEST %-2s %-30s : FAIL" $num $name]
    }
}

proc compile_file {file} {
    if {[catch {vlog -sv -work work $file} result]} {
        puts "ERROR: Compilation failed:"
        puts $result
        quit -code 1
    }
}

proc run_uvm_test {num name testname} {
    global PASS_COUNT FAIL_COUNT

    puts ""
    puts "============================================================"
    puts "TEST $num: $name"
    puts "============================================================"

    if {[catch {
        vsim -c \
            -voptargs=+acc \
            -onfinish stop \
            work.tb_top \
            +UVM_TESTNAME=$testname

        run -all

        quit -sim
    } result]} {
        puts "Simulation exception:"
        puts $result
        print_test_result $num $name FAIL
    } else {
        print_test_result $num $name PASS
    }
}

proc run_standalone_test {num name top} {
    puts ""
    puts "============================================================"
    puts "TEST $num: $name"
    puts "============================================================"

    if {[catch {
        vsim -c \
            -onfinish stop \
            work.$top

        run -all

        quit -sim
    } result]} {
        puts "Simulation exception:"
        puts $result
        print_test_result $num $name FAIL
    } else {
        print_test_result $num $name PASS
    }
}


# ============================================================
# START
# ============================================================

puts ""
puts "============================================================"
puts "          AHB-to-APB BRIDGE UVM REGRESSION"
puts "============================================================"
puts ""

# ============================================================
# CLEAN WORK LIBRARY
# ============================================================

catch {quit -sim}

if {[file exists work]} {
    catch {vdel -lib work -all}
}

vlib work
vmap work work


# ============================================================
# COMPILE RTL
# ============================================================

puts "============================================================"
puts "STEP 1: COMPILE RTL"
puts "============================================================"

compile_file $ROOT/rtl/SRAM.sv
compile_file $ROOT/rtl/SRAM_CONTROLL.sv
compile_file $ROOT/rtl/ahbtoapb.sv

puts "RTL compilation: PASS"


# ============================================================
# COMPILE SVA
# ============================================================

puts ""
puts "============================================================"
puts "STEP 2: COMPILE SVA"
puts "============================================================"

if {[catch {
    vlog -sv -work work \
        +incdir+$UVM \
        +incdir+$ROOT \
        $ROOT/assertions/ahb_apb_assertions.sv
} result]} {
    puts "SVA compilation: FAIL"
    puts $result
    quit -code 1
}

puts "SVA compilation: PASS"


# ============================================================
# COMPILE AHB INTERFACE
# ============================================================

puts ""
puts "============================================================"
puts "STEP 3: COMPILE AHB INTERFACE"
puts "============================================================"

if {[catch {
    vlog -sv -work work \
        +incdir+$UVM \
        +incdir+$ROOT \
        $ROOT/interface/ahb_if.sv
} result]} {
    puts "AHB interface compilation: FAIL"
    puts $result
    quit -code 1
}

puts "AHB interface compilation: PASS"


# ============================================================
# COMPILE UVM PACKAGE
# ============================================================

puts ""
puts "============================================================"
puts "STEP 4: COMPILE UVM PACKAGE"
puts "============================================================"

if {[catch {
    vlog -sv -work work \
        +incdir+$UVM \
        +incdir+$ROOT \
        $ROOT/ahb_uvm_pkg.sv
} result]} {
    puts "UVM package compilation: FAIL"
    puts $result
    quit -code 1
}

puts "UVM package compilation: PASS"


# ============================================================
# COMPILE UVM TOP
# ============================================================

puts ""
puts "============================================================"
puts "STEP 5: COMPILE UVM TOP"
puts "============================================================"

if {[catch {
    vlog -sv -work work \
        +incdir+$UVM \
        +incdir+$ROOT \
        $ROOT/top/tb_top.sv
} result]} {
    puts "UVM top compilation: FAIL"
    puts $result
    quit -code 1
}

puts "UVM top compilation: PASS"


# ============================================================
# TEST 1 - BASIC WRITE/READ
# ============================================================

run_uvm_test 1 "BASIC WRITE/READ" write_read_test


# ============================================================
# TEST 2 - MULTIPLE WRITE/READ
# ============================================================

run_uvm_test 2 "MULTIPLE WRITE/READ" multi_write_read_test


# ============================================================
# TEST 3 - INCR BURST
# ============================================================

run_uvm_test 3 "INCR BURST" burst_test


# ============================================================
# TEST 4 - SVA VIOLATION
# ============================================================

puts ""
puts "============================================================"
puts "TEST 4: SVA SETUP -> ACCESS VIOLATION"
puts "============================================================"

if {[catch {
    vlog -sv -work work \
        +incdir+$ROOT \
        $ROOT/assertions/tb/sva_violation_tb.sv

    vsim -c \
        -onfinish stop \
        work.sva_violation_tb

    run -all

    quit -sim
} result]} {
    puts "Unexpected SVA test failure:"
    puts $result
    print_test_result 4 "SVA VIOLATION CHECK" FAIL
} else {
    puts "Expected assertion violation was observed."
    print_test_result 4 "SVA VIOLATION CHECK" PASS
}


# ============================================================
# TEST 5 - APB WAIT STATE
# ============================================================

if {[catch {
    vlog -sv -work work \
        +incdir+$ROOT \
        $ROOT/assertions/tb/wait_state_tb.sv

    vsim -c \
        -onfinish stop \
        work.wait_state_tb

    run -all

    quit -sim
} result]} {
    puts "Wait-state test failure:"
    puts $result
    print_test_result 5 "APB WAIT STATE" FAIL
} else {
    print_test_result 5 "APB WAIT STATE" PASS
}


# ============================================================
# TEST 6 - APB ERROR RESPONSE
# ============================================================

if {[catch {
    vlog -sv -work work \
        +incdir+$ROOT \
        $ROOT/assertions/tb/error_response_tb.sv

    vsim -c \
        -onfinish stop \
        work.error_response_tb

    run -all

    quit -sim
} result]} {
    puts "Error-response test failure:"
    puts $result
    print_test_result 6 "APB ERROR RESPONSE" FAIL
} else {
    print_test_result 6 "APB ERROR RESPONSE" PASS
}


# ============================================================
# FINAL REGRESSION SUMMARY
# ============================================================

puts ""
puts ""
puts "============================================================"
puts "              REGRESSION SUMMARY"
puts "============================================================"
puts ""

puts [format "Total tests     : %d" $TOTAL_TESTS]
puts [format "Tests passed    : %d" $PASS_COUNT]
puts [format "Tests failed    : %d" $FAIL_COUNT]

puts ""
puts "------------------------------------------------------------"
puts "TEST RESULTS"
puts "------------------------------------------------------------"

if {$FAIL_COUNT == 0} {
    puts ""
    puts "TEST 1  BASIC WRITE/READ       : PASS"
    puts "TEST 2  MULTIPLE WRITE/READ    : PASS"
    puts "TEST 3  INCR BURST              : PASS"
    puts "TEST 4  SVA VIOLATION           : PASS"
    puts "TEST 5  APB WAIT STATE          : PASS"
    puts "TEST 6  APB ERROR RESPONSE      : PASS"
} else {
    puts ""
    puts "One or more tests FAILED."
}

puts ""
puts "============================================================"

if {$FAIL_COUNT == 0} {
    puts "             REGRESSION STATUS: PASS"
    puts "============================================================"
    puts ""
    quit -code 0
} else {
    puts "             REGRESSION STATUS: FAIL"
    puts "============================================================"
    puts ""
    quit -code 1
}
EOF
