quit -sim

vlib work
vmap work work

vlog -sv rtl/SRAM.sv
vlog -sv rtl/SRAM_CONTROLL.sv
vlog -sv rtl/ahbtoapb.sv
vlog -sv top/tb_top.sv

vsim -voptargs=+acc -onfinish stop work.tb_top

add wave sim:/tb_top/HCLK
add wave sim:/tb_top/HRESETn
add wave sim:/tb_top/HSEL
add wave sim:/tb_top/HWRITE
add wave sim:/tb_top/HADDR
add wave sim:/tb_top/HWDATA
add wave sim:/tb_top/HRDATA
add wave sim:/tb_top/HREADY
add wave sim:/tb_top/HBURST
add wave sim:/tb_top/HRESP

add wave sim:/tb_top/PSEL
add wave sim:/tb_top/PENABLE
add wave sim:/tb_top/PWRITE
add wave sim:/tb_top/PADDR
add wave sim:/tb_top/PWDATA
add wave sim:/tb_top/PRDATA
add wave sim:/tb_top/PREADY

run -all
wave zoom full
