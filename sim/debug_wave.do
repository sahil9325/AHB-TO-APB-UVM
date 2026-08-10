catch {delete wave *}
view wave

add wave -divider "===== TOP / AHB APB ====="
add wave -r sim:/tb_top/*

add wave -divider "===== BRIDGE ====="
add wave -r sim:/tb_top/bridge/*

add wave -divider "===== SRAM CONTROLLER ====="
add wave -r sim:/tb_top/sram_ctrl/*

add wave -divider "===== SRAM ====="
add wave -r sim:/tb_top/sram_ctrl/mem/*

run 100ns
