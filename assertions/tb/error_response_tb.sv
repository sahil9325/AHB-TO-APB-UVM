`timescale 1ns/1ps

module error_response_tb;

    logic HCLK;
    logic HRESETn;

    // =========================================================
    // AHB
    // =========================================================

    logic        HSEL;
    logic [31:0] HADDR;
    logic        HWRITE;
    logic [31:0] HWDATA;
    logic [2:0]  HBURST;

    logic [31:0] HRDATA;
    logic        HREADY;
    logic        HRESP;

    // =========================================================
    // APB
    // =========================================================

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;

    // =========================================================
    // Clock
    // =========================================================

    initial begin
        HCLK = 1'b0;
        forever #5 HCLK = ~HCLK;
    end

    // =========================================================
    // DUT
    // =========================================================

    ahb_apb_bridge dut (

        .HCLK    (HCLK),
        .HRESETn (HRESETn),

        .HSEL    (HSEL),
        .HADDR   (HADDR),
        .HWRITE  (HWRITE),
        .HWDATA  (HWDATA),
        .HBURST  (HBURST),

        .HRDATA  (HRDATA),
        .HREADY  (HREADY),
        .HRESP   (HRESP),

        .PSEL    (PSEL),
        .PENABLE (PENABLE),
        .PWRITE  (PWRITE),
        .PADDR   (PADDR),
        .PWDATA  (PWDATA),

        .PRDATA  (PRDATA),
        .PREADY  (PREADY),
        .PSLVERR (PSLVERR)
    );

    // =========================================================
    // APB ERROR-INJECTION SLAVE
    //
    // Normal APB completion:
    //     PREADY  = 1
    //     PSLVERR = 0
    //
    // Error completion:
    //     PREADY  = 1
    //     PSLVERR = 1
    // =========================================================

    always_comb begin

        PRDATA  = 32'h00000000;
        PREADY  = 1'b0;
        PSLVERR = 1'b0;

        if (PSEL && PENABLE) begin

            PREADY = 1'b1;

            // Intentionally inject APB error.
            PSLVERR = 1'b1;

            PRDATA = 32'hBAD0_BAD0;

        end

    end

    // =========================================================
    // DEBUG
    // =========================================================

    always @(posedge HCLK) begin

        $display(
            "[ERROR_TEST] t=%0t STATE=%0d HSEL=%0b HWRITE=%0b HADDR=%08h | PSEL=%0b PENABLE=%0b PREADY=%0b PSLVERR=%0b | HREADY=%0b HRESP=%0b",
            $time,
            dut.current_state,
            HSEL,
            HWRITE,
            HADDR,
            PSEL,
            PENABLE,
            PREADY,
            PSLVERR,
            HREADY,
            HRESP
        );

    end

    // =========================================================
    // TEST
    // =========================================================

    initial begin

        // -----------------------------------------------------
        // Initial values
        // -----------------------------------------------------

        HRESETn = 1'b0;

        HSEL   = 1'b0;
        HADDR  = 32'h00000000;
        HWRITE = 1'b0;
        HWDATA = 32'h00000000;
        HBURST = 3'b000;

        // -----------------------------------------------------
        // Reset
        // -----------------------------------------------------

        repeat (2) @(posedge HCLK);

        HRESETn = 1'b1;

        // -----------------------------------------------------
        // Generate AHB WRITE
        // -----------------------------------------------------

        @(posedge HCLK);

        HSEL   <= 1'b1;
        HADDR  <= 32'h00000040;
        HWRITE <= 1'b1;
        HWDATA <= 32'hDEADBEEF;
        HBURST <= 3'b000;

        // -----------------------------------------------------
        // Hold request for one cycle
        // -----------------------------------------------------

        @(posedge HCLK);

        HSEL <= 1'b0;

        // -----------------------------------------------------
        // Wait for APB ACCESS
        // -----------------------------------------------------

        wait (PSEL === 1'b1 && PENABLE === 1'b1);

        $display("");
        $display("==============================================");
        $display("[ERROR_TEST] APB ACCESS PHASE REACHED");
        $display("[ERROR_TEST] PSLVERR = %0b", PSLVERR);
        $display("==============================================");
        $display("");

        // -----------------------------------------------------
        // Verify APB error is asserted
        // -----------------------------------------------------

        if (PSLVERR !== 1'b1) begin

            $error(
                "[ERROR_TEST] FAIL: PSLVERR was not asserted"
            );

        end
        else begin

            $display(
                "[ERROR_TEST] PASS: APB PSLVERR asserted"
            );

        end

        // -----------------------------------------------------
        // Wait for AHB completion
        // -----------------------------------------------------

        wait (HREADY === 1'b1);

        // -----------------------------------------------------
        // Verify HRESP propagation
        // -----------------------------------------------------

        if (HRESP !== 1'b1) begin

            $error(
                "[ERROR_TEST] FAIL: HRESP did not propagate APB error"
            );

        end
        else begin

            $display(
                "[ERROR_TEST] PASS: HRESP correctly asserted"
            );

        end

        // -----------------------------------------------------
        // Final result
        // -----------------------------------------------------

        if ((PSLVERR === 1'b1) &&
            (HREADY  === 1'b1) &&
            (HRESP   === 1'b1)) begin

            $display("");
            $display("==============================================");
            $display("APB ERROR RESPONSE TEST PASSED");
            $display("==============================================");
            $display("PSLVERR = 1");
            $display("HREADY  = 1");
            $display("HRESP   = 1");
            $display("APB error successfully propagated to AHB");
            $display("==============================================");
            $display("");

        end
        else begin

            $error(
                "[ERROR_TEST] ERROR RESPONSE TEST FAILED"
            );

        end

        #20;

        $finish;

    end

endmodule
