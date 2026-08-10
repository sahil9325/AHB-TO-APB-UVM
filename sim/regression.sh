#!/bin/bash

# ============================================================
# AHB-to-APB BRIDGE
# Automated UVM + SVA Regression
# ============================================================

set -u

ROOT="/home/sahil/majorproj"
QUESTA="/home/sahil/questa/questa_fse/linux_x86_64"
UVM="/home/sahil/questa/questa_fse/verilog_src/uvm-1.1d/src"

VLOG="$QUESTA/vlog"
VSIM="$QUESTA/vsim"

WORK="$ROOT/work"
LOGDIR="$ROOT/sim/logs"
REPORT="$ROOT/sim/regression_report.txt"

mkdir -p "$LOGDIR"

PASS=0
FAIL=0
TOTAL=0

# ------------------------------------------------------------
# Report header
# ------------------------------------------------------------

{
    echo "============================================================"
    echo "        AHB-to-APB BRIDGE VERIFICATION REGRESSION"
    echo "============================================================"
    echo ""
    echo "Date: $(date)"
    echo ""
} | tee "$REPORT"

# ------------------------------------------------------------
# Clean simulation library
# ------------------------------------------------------------

echo "[REGRESSION] Cleaning simulation library..."

if [ -d "$WORK" ]; then
    "$QUESTA/vdel" -lib "$WORK" -all >/dev/null 2>&1 || true
fi

"$QUESTA/vlib" "$WORK" >/dev/null
"$QUESTA/vmap" work "$WORK" >/dev/null

# ------------------------------------------------------------
# Compile RTL
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 1: COMPILING RTL"
echo "============================================================"

"$VLOG" -sv -work work \
    "$ROOT/rtl/SRAM.sv" \
    "$ROOT/rtl/SRAM_CONTROLL.sv" \
    "$ROOT/rtl/ahbtoapb.sv"

if [ $? -ne 0 ]; then
    echo "FATAL: RTL compilation failed."
    exit 1
fi

# ------------------------------------------------------------
# Compile UVM package
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 2: COMPILING UVM ENVIRONMENT"
echo "============================================================"

"$VLOG" -sv -work work \
    "+incdir+$UVM" \
    "+incdir+$ROOT" \
    "$ROOT/ahb_uvm_pkg.sv"

if [ $? -ne 0 ]; then
    echo "FATAL: UVM package compilation failed."
    exit 1
fi
# ------------------------------------------------------------
# Compile AHB interface
# ------------------------------------------------------------

"$VLOG" -sv -work work \
    "+incdir+$UVM" \
    "+incdir+$ROOT" \
    "$ROOT/interface/ahb_if.sv"

if [ $? -ne 0 ]; then
    echo "FATAL: AHB interface compilation failed."
    exit 1
fi
# ------------------------------------------------------------
# Compile UVM top
# ------------------------------------------------------------

"$VLOG" -sv -work work \
    "+incdir+$UVM" \
    "+incdir+$ROOT" \
    "$ROOT/top/tb_top.sv"

if [ $? -ne 0 ]; then
    echo "FATAL: UVM top compilation failed."
    exit 1
fi

# ------------------------------------------------------------
# Compile SVA testbenches
# ------------------------------------------------------------

echo ""
echo "============================================================"
echo "STEP 3: COMPILING SVA TESTBENCHES"
echo "============================================================"

"$VLOG" -sv -work work \
    "$ROOT/assertions/ahb_apb_assertions.sv" \
    "$ROOT/assertions/tb/sva_violation_tb.sv" \
    "$ROOT/assertions/tb/wait_state_tb.sv" \
    "$ROOT/assertions/tb/error_response_tb.sv"

if [ $? -ne 0 ]; then
    echo "FATAL: SVA testbench compilation failed."
    exit 1
fi

# ============================================================
# Function: run UVM test
# ============================================================

run_uvm_test()
{
    TEST_NAME="$1"
    LABEL="$2"
    LOG="$LOGDIR/${TEST_NAME}.log"

    TOTAL=$((TOTAL + 1))

    echo ""
    echo "------------------------------------------------------------"
    echo "RUNNING: $LABEL"
    echo "------------------------------------------------------------"

    "$VSIM" -c \
        -onfinish stop \
        work.tb_top \
        "+UVM_TESTNAME=$TEST_NAME" \
        -do "run -all; quit -f" \
        > "$LOG" 2>&1

    STATUS=$?

    if grep -q "UVM_FATAL.*:[[:space:]]*[1-9]" "$LOG" || \
       grep -q "UVM_ERROR.*:[[:space:]]*[1-9]" "$LOG"; then

        STATUS=1
    fi

    if [ "$STATUS" -eq 0 ]; then
        echo "$LABEL : PASS" | tee -a "$REPORT"
        PASS=$((PASS + 1))
    else
        echo "$LABEL : FAIL" | tee -a "$REPORT"
        FAIL=$((FAIL + 1))
    fi

    # Show coverage summary if present
    grep "\[COVERAGE\].*functional coverage" "$LOG" | tail -1 || true
}

# ============================================================
# Function: run standalone test
# ============================================================

run_tb_test()
{
    TOP="$1"
    LABEL="$2"

    LOG="$LOGDIR/${TOP}.log"

    TOTAL=$((TOTAL + 1))

    echo ""
    echo "------------------------------------------------------------"
    echo "RUNNING: $LABEL"
    echo "------------------------------------------------------------"

    "$VSIM" -c \
        -onfinish stop \
        "work.$TOP" \
        -do "run -all; quit -f" \
        > "$LOG" 2>&1

    STATUS=$?

    # These tests intentionally contain assertion failures.
    # Therefore we determine PASS from their explicit completion
    # messages rather than simulator error count.

    case "$TOP" in

        sva_violation_tb)
            if grep -q "SVA SETUP -> ACCESS VIOLATION TEST COMPLETED" "$LOG"; then
                STATUS=0
            else
                STATUS=1
            fi
            ;;

        wait_state_tb)
            if grep -q "APB WAIT-STATE TEST PASSED" "$LOG"; then
                STATUS=0
            else
                STATUS=1
            fi
            ;;

        error_response_tb)
            if grep -q "APB ERROR RESPONSE TEST PASSED" "$LOG"; then
                STATUS=0
            else
                STATUS=1
            fi
            ;;

    esac

    if [ "$STATUS" -eq 0 ]; then
        echo "$LABEL : PASS" | tee -a "$REPORT"
        PASS=$((PASS + 1))
    else
        echo "$LABEL : FAIL" | tee -a "$REPORT"
        FAIL=$((FAIL + 1))
    fi
}

# ============================================================
# UVM REGRESSION
# ============================================================

echo ""
echo "============================================================"
echo "STEP 4: UVM REGRESSION"
echo "============================================================"

run_uvm_test \
    "write_read_test" \
    "TEST 1  BASIC WRITE/READ"

run_uvm_test \
    "multi_write_read_test" \
    "TEST 2  MULTIPLE WRITE/READ"

run_uvm_test \
    "burst_test" \
    "TEST 3  INCR BURST"

run_uvm_test \
    "coverage_test" \
    "TEST 4  COVERAGE CLOSURE"

# ============================================================
# SVA / PROTOCOL REGRESSION
# ============================================================

echo ""
echo "============================================================"
echo "STEP 5: SVA / PROTOCOL REGRESSION"
echo "============================================================"

run_tb_test \
    "sva_violation_tb" \
    "TEST 5  SVA VIOLATION"

run_tb_test \
    "wait_state_tb" \
    "TEST 6  APB WAIT STATE"

run_tb_test \
    "error_response_tb" \
    "TEST 7  APB ERROR RESPONSE"

# ============================================================
# Final report
# ============================================================

echo "" | tee -a "$REPORT"

echo "============================================================" | tee -a "$REPORT"
echo "                 REGRESSION SUMMARY" | tee -a "$REPORT"
echo "============================================================" | tee -a "$REPORT"

echo "" | tee -a "$REPORT"
echo "Total tests     : $TOTAL" | tee -a "$REPORT"
echo "Tests passed    : $PASS" | tee -a "$REPORT"
echo "Tests failed    : $FAIL" | tee -a "$REPORT"

echo "" | tee -a "$REPORT"

if [ "$FAIL" -eq 0 ]; then
    echo "REGRESSION STATUS : PASS" | tee -a "$REPORT"
    echo "============================================================" | tee -a "$REPORT"
    exit 0
else
    echo "REGRESSION STATUS : FAIL" | tee -a "$REPORT"
    echo "============================================================" | tee -a "$REPORT"
    exit 1
fi
