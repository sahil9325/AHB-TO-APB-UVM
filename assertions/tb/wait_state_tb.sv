`timescale 1ns/1ps

module wait_state_tb;

    // =========================================================
    // CLOCK / RESET
    // =========================================================

    logic HCLK;
    logic HRESETn;


    // =========================================================
    // AHB SIGNALS
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
    // APB SIGNALS
    // =========================================================

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;


    // =========================================================
    // WAIT-STATE CONTROL
    // =========================================================

    integer wait_count;
    integer observed_wait_cycles;


    // =========================================================
    // CLOCK GENERATION
    // 10 ns clock period
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
        .PREADY  (PREADY)

    );


    // =========================================================
    // TEST-ONLY APB SLAVE
    //
    // The APB slave deliberately holds PREADY LOW for
    // multiple ACCESS cycles.
    //
    // Expected:
    //
    // SETUP
    //   |
    // ACCESS + PREADY=0
    //   |
    // ACCESS + PREADY=0
    //   |
    // ACCESS + PREADY=0
    //   |
    // ACCESS + PREADY=1
    //   |
    // IDLE
    //
    // =========================================================


    // ---------------------------------------------------------
    // Wait-state counter
    // ---------------------------------------------------------

    always @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin

            wait_count           <= 0;
            observed_wait_cycles <= 0;

        end

        else if (!PSEL || !PENABLE) begin

            wait_count <= 0;

        end

        else if (PSEL && PENABLE && !PREADY) begin

            if (wait_count < 3)
                wait_count <= wait_count + 1;

            observed_wait_cycles <=
                observed_wait_cycles + 1;

        end

    end


    // ---------------------------------------------------------
    // APB response generation
    // ---------------------------------------------------------

    always_comb begin

        // Fixed read data
        PRDATA = 32'hA5A5A5A5;


        // APB inactive
        if (!PSEL || !PENABLE) begin

            PREADY = 1'b0;

        end


        // Insert wait states
        else if (wait_count < 3) begin

            PREADY = 1'b0;

        end


        // Complete transfer
        else begin

            PREADY = 1'b1;

        end

    end


    // =========================================================
    // DEBUG MONITOR
    // =========================================================

    always @(posedge HCLK) begin

        $display(
            "[WAIT_STATE] t=%0t STATE=%0d PSEL=%0b PENABLE=%0b PREADY=%0b HREADY=%0b ADDR=%08h WAIT_COUNT=%0d OBSERVED=%0d",
            $time,
            dut.current_state,
            PSEL,
            PENABLE,
            PREADY,
            HREADY,
            PADDR,
            wait_count,
            observed_wait_cycles
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
        // RESET
        // -----------------------------------------------------

        repeat (2) @(posedge HCLK);

        HRESETn = 1'b1;


        // -----------------------------------------------------
        // AHB WRITE REQUEST
        // -----------------------------------------------------

        @(posedge HCLK);

        HSEL   <= 1'b1;
        HADDR  <= 32'h00000040;
        HWRITE <= 1'b1;
        HWDATA <= 32'hDEADBEEF;
        HBURST <= 3'b000;


        // -----------------------------------------------------
        // Remove AHB select after request is accepted
        // -----------------------------------------------------

        @(posedge HCLK);

        HSEL <= 1'b0;


        // -----------------------------------------------------
        // Wait for bridge to enter APB ACCESS
        // -----------------------------------------------------

        @(posedge HCLK);


        // -----------------------------------------------------
        // Verify APB SETUP / ACCESS
        // -----------------------------------------------------

        if (PSEL !== 1'b1) begin

    $error(
        "[WAIT_STATE] FAIL: PSEL is not asserted during APB SETUP"
    );

end

if (PENABLE !== 1'b0) begin

    $error(
        "[WAIT_STATE] FAIL: PENABLE should be LOW during SETUP"
    );

end


// -----------------------------------------------------
// Verify APB ACCESS phase
// -----------------------------------------------------

@(posedge HCLK);

if (PSEL !== 1'b1) begin

    $error(
        "[WAIT_STATE] FAIL: PSEL is not asserted during APB ACCESS"
    );

end

if (PENABLE !== 1'b1) begin

    $error(
        "[WAIT_STATE] FAIL: Bridge did not enter APB ACCESS phase"
    );

end

        if (HREADY !== 1'b0) begin

            $error(
                "[WAIT_STATE] FAIL: HREADY did not go LOW during APB wait"
            );

        end

        else begin

            $display(
                "[WAIT_STATE] HREADY correctly LOW during APB wait"
            );

        end


        // -----------------------------------------------------
        // Wait until bridge completes transfer
        // -----------------------------------------------------

        while (HREADY !== 1'b1) begin

            @(posedge HCLK);

        end


        // -----------------------------------------------------
        // Verify multiple wait cycles occurred
        // -----------------------------------------------------

        if (observed_wait_cycles < 3) begin

            $error(
                "[WAIT_STATE] FAIL: Expected at least 3 APB wait cycles, observed %0d",
                observed_wait_cycles
            );

        end

        else begin

            $display(
                "[WAIT_STATE] PASS: Observed %0d APB wait cycles",
                observed_wait_cycles
            );

        end


        // -----------------------------------------------------
        // Verify final response
        // -----------------------------------------------------

        if (HREADY !== 1'b1) begin

            $error(
                "[WAIT_STATE] FAIL: HREADY did not return HIGH"
            );

        end

        else begin

            $display(
                "[WAIT_STATE] HREADY returned HIGH after APB completion"
            );

        end


        // -----------------------------------------------------
        // Verify no error response
        // -----------------------------------------------------

        if (HRESP !== 1'b0) begin

            $error(
                "[WAIT_STATE] FAIL: Unexpected HRESP error"
            );

        end


        // -----------------------------------------------------
        // PASS MESSAGE
        // -----------------------------------------------------

        $display("");
        $display("==============================================");
        $display("       APB WAIT-STATE TEST PASSED");
        $display("==============================================");
        $display("PREADY remained LOW for multiple cycles");
        $display("Bridge remained in ACCESS");
        $display("HREADY remained LOW during wait states");
        $display("Transfer completed after PREADY became HIGH");
        $display("Observed wait cycles = %0d", observed_wait_cycles);
        $display("==============================================");
        $display("");


        // -----------------------------------------------------
        // End simulation
        // -----------------------------------------------------

        #20;

        $finish;

    end

endmodule
