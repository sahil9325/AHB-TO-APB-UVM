echo "========================================"
echo " AHB-APB UVM DEBUG"
echo "========================================"

echo "Adding AHB signals..."

add wave /tb_top/ahb_vif/HCLK
add wave /tb_top/ahb_vif/HSEL
add wave /tb_top/ahb_vif/HWRITE
add wave /tb_top/ahb_vif/HADDR
add wave /tb_top/ahb_vif/HWDATA
add wave /tb_top/ahb_vif/HBURST
add wave /tb_top/ahb_vif/HREADY
add wave /tb_top/ahb_vif/HRDATA
add wave /tb_top/ahb_vif/HRESP

echo "Adding APB signals..."

add wave /tb_top/PSEL
add wave /tb_top/PENABLE
add wave /tb_top/PWRITE
add wave /tb_top/PADDR
add wave /tb_top/PWDATA
add wave /tb_top/PRDATA
add wave /tb_top/PREADY

echo "========================================"
echo " Starting simulation"
echo "========================================"

run -all

echo "========================================"
echo " Simulation stopped"
echo "========================================"

echo "AHB HSEL:"
examine /tb_top/ahb_vif/HSEL

echo "AHB HREADY:"
examine /tb_top/ahb_vif/HREADY

echo "AHB HWRITE:"
examine /tb_top/ahb_vif/HWRITE

echo "AHB HADDR:"
examine /tb_top/ahb_vif/HADDR

echo "AHB HWDATA:"
examine /tb_top/ahb_vif/HWDATA

echo "APB PSEL:"
examine /tb_top/PSEL

echo "APB PENABLE:"
examine /tb_top/PENABLE

echo "APB PWRITE:"
examine /tb_top/PWRITE

echo "APB PADDR:"
examine /tb_top/PADDR

echo "APB PWDATA:"
examine /tb_top/PWDATA

echo "APB PREADY:"
examine /tb_top/PREADY

echo "APB PRDATA:"
examine /tb_top/PRDATA

echo "========================================"
echo " DEBUG COMPLETE"
echo "========================================"
