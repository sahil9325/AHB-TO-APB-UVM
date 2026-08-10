`timescale 1ns/1ps
`default_nettype none

module tb_top;

    import uvm_pkg::*;
    import ahb_uvm_pkg::*;

    logic HCLK;
    logic HRESETn;

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;

    ahb_if ahb_vif (HCLK);

    // AHB -> APB bridge
    ahb_apb_bridge bridge (
        .HCLK    (HCLK),
        .HRESETn (HRESETn),
        .HSEL    (ahb_vif.HSEL),
        .HADDR   (ahb_vif.HADDR),
        .HWRITE  (ahb_vif.HWRITE),
        .HWDATA  (ahb_vif.HWDATA),
        .HBURST  (ahb_vif.HBURST),
        .HRDATA  (ahb_vif.HRDATA),
        .HREADY  (ahb_vif.HREADY),
        .HRESP   (ahb_vif.HRESP),
        .PSEL    (PSEL),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),
        .PRDATA  (PRDATA),
        .PREADY  (PREADY)
    );

    // APB -> SRAM controller
    // IMPORTANT: this was commented out in your old tb_top.
    // Without it, PREADY is undriven and becomes X.
    apb_sram_ctrl sram_ctrl (

        .PCLK    (HCLK),
        .PRESETn (HRESETn),

        .PSEL    (PSEL),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),

        .PRDATA  (PRDATA),
        .PREADY  (PREADY)

    );

    // 100 MHz clock
    initial begin
        HCLK = 1'b0;
        forever #5 HCLK = ~HCLK;
    end

    // DUT reset
    initial begin

        // Assert reset
        HRESETn         = 1'b0;
        ahb_vif.HRESETn = 1'b0;

    // Hold reset for 3 clock cycles
        repeat (3)
            @(posedge HCLK);

    // Release reset
        HRESETn         = 1'b1;
        ahb_vif.HRESETn = 1'b1;

    // Give the DUT one complete clock cycle
    // after reset release before UVM drives anything
        @(posedge HCLK);

    end
    // UVM configuration
    initial begin
        uvm_config_db#(virtual ahb_if)::set(
            null,
            "*",
            "vif",
            ahb_vif
        );
        run_test();
    end
    initial begin
        forever begin
            @(posedge HCLK);
 
            $display(
                "[APB_DEBUG] t=%0t STATE=%0d HSEL=%0b HWRITE=%0b HADDR=%08h HWDATA=%08h | PSEL=%0b PENABLE=%0b PWRITE=%0b PADDR=%08h PWDATA=%08h PREADY=%0b PRDATA=%08h",
                $time,
                bridge.current_state,
                ahb_vif.HSEL,
                ahb_vif.HWRITE,
                ahb_vif.HADDR,
                ahb_vif.HWDATA,
                PSEL,
                PENABLE,
                PWRITE,
                PADDR,
                PWDATA,
                PREADY,
                PRDATA
            );
         end
     end

endmodule

`default_nettype wire

