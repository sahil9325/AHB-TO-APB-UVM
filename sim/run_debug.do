# ============================================================
# AHB-to-APB UVM Automated Debug Script
# ============================================================

transcript on

# ------------------------------------------------------------
# Compile UVM package
# ------------------------------------------------------------
vlog -sv -work work \
+incdir+/home/sahil/questa/questa_fse/verilog_src/uvm-1.1d/src \
+incdir+/home/sahil/majorproj \
/home/sahil/majorproj/ahb_uvm_pkg.sv

# ------------------------------------------------------------
# Compile RTL
# ------------------------------------------------------------
vlog -sv -work work \
/home/sahil/majorproj/rtl/SRAM.sv

vlog -sv -work work \
/home/sahil/majorproj/rtl/SRAM_CONTROLL.sv

vlog -sv -work work \
/home/sahil/majorproj/rtl/ahbtoapb.sv

# ------------------------------------------------------------
# Compile testbench
# ------------------------------------------------------------
vlog -sv -work work \
+incdir+/home/sahil/questa/questa_fse/verilog_src/uvm-1.1d/src \
+incdir+/home/sahil/majorproj \
/home/sahil/majorproj/top/tb_top.sv

# ------------------------------------------------------------
# Load simulation
# ------------------------------------------------------------
vsim -voptargs="+acc" \
-onfinish stop \
work.tb_top \
+UVM_TESTNAME=write_read_test

# ------------------------------------------------------------
# Waveform
# ------------------------------------------------------------
catch {delete wave *}
view wave

# ------------------------------------------------------------
# Add EVERYTHING under tb_top
# ------------------------------------------------------------
add wave -divider "========== TOP =========="
add wave -r sim:/tb_top/*

# ------------------------------------------------------------
# Bridge
# ------------------------------------------------------------
add wave -divider "========== AHB-APB BRIDGE =========="
add wave -r sim:/tb_top/bridge/*

# ------------------------------------------------------------
# SRAM controller
# ------------------------------------------------------------
add wave -divider "========== SRAM CONTROLLER =========="
add wave -r sim:/tb_top/sram_ctrl/*

# ------------------------------------------------------------
# SRAM
# ------------------------------------------------------------
add wave -divider "========== SRAM =========="
add wave -r sim:/tb_top/sram_ctrl/mem/*

# ------------------------------------------------------------
# Start simulation
# ------------------------------------------------------------
echo "=================================================="
echo " AHB-to-APB UVM DEBUG"
echo " Running simulation..."
echo "=================================================="

run 100ns

echo "=================================================="
echo " Simulation stopped at 100 ns"
echo " Inspect waveform"
echo "=================================================="
