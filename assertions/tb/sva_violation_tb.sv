`timescale 1ns/1ps

module sva_violation_tb;

    logic HCLK;
    logic HRESETn;

    logic        HSEL;
    logic        HWRITE;
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic [31:0] HRDATA;
    logic        HREADY;
    logic        HRESP;

    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;
    // =========================================================
    // CLOCK
    // =========================================================

    initial begin
        HCLK = 1'b0;
        forever #5 HCLK = ~HCLK;
    end

    // =========================================================
    // SVA CHECKER
    // =========================================================

    ahb_apb_assertions sva_checker (

        .HCLK    (HCLK),
        .HRESETn (HRESETn),

        .HSEL    (HSEL),
        .HWRITE  (HWRITE),
        .HADDR   (HADDR),
        .HWDATA  (HWDATA),
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
    // TEST
    // =========================================================

    initial begin

        // Initial/reset values
        HRESETn = 1'b0;

        HSEL    = 1'b0;
        HWRITE  = 1'b0;
        HADDR   = 32'h0;
        HWDATA  = 32'h0;
        HRDATA  = 32'h0;
        HREADY  = 1'b1;
        HRESP   = 1'b0;

        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = 1'b0;
        PADDR   = 32'h0;
        PWDATA  = 32'h0;
        PRDATA  = 32'h0;
        PREADY  = 1'b0;
        PSLVERR = 1'b0;

        // Release reset
        repeat (2) @(posedge HCLK);
        HRESETn = 1'b1;

        // =====================================================
        // INTENTIONAL APB SETUP -> ACCESS VIOLATION
        // =====================================================

        @(posedge HCLK);

        // Valid SETUP phase
        PSEL    <= 1'b1;
        PENABLE <= 1'b0;

        @(posedge HCLK);

        // INTENTIONALLY WRONG:
        // SETUP should become ACCESS here.
        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

        @(posedge HCLK);

        PSEL    <= 1'b0;
        PENABLE <= 1'b0;

        #20;

        $display("");
        $display("==============================================");
        $display("SVA SETUP -> ACCESS VIOLATION TEST COMPLETED");
        $display("Expected: SETUP-to-ACCESS assertion failure");
        $display("==============================================");
        $display("");

        $finish;

    end

endmodule
