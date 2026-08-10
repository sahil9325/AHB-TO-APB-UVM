module ahb_apb_assertions (

    input logic        HCLK,
    input logic        HRESETn,

    // AHB
    input logic        HSEL,
    input logic        HWRITE,
    input logic [31:0] HADDR,
    input logic [31:0] HWDATA,
    input logic [31:0] HRDATA,
    input logic        HREADY,
    input logic        HRESP,

    // APB
    input logic        PSEL,
    input logic        PENABLE,
    input logic        PWRITE,
    input logic [31:0] PADDR,
    input logic [31:0] PWDATA,
    input logic [31:0] PRDATA,
    input logic        PREADY

);

    default clocking cb @(posedge HCLK);
    endclocking

    // =========================================================
    // RESET
    // =========================================================

    // During reset the APB interface must be inactive.
    property p_reset_apb_idle;
        !HRESETn |-> (!PSEL && !PENABLE);
    endproperty

    assert property (p_reset_apb_idle)
        else $error("[SVA] APB active during reset");


    // =========================================================
    // APB PROTOCOL
    // =========================================================

    // PENABLE can never be asserted without PSEL.
    property p_penable_requires_psel;
        PENABLE |-> PSEL;
    endproperty

    assert property (p_penable_requires_psel)
        else $error("[SVA] PENABLE asserted without PSEL");


    // Every APB setup phase must be followed by an access phase.
    property p_setup_to_access;
        (PSEL && !PENABLE) |=> (PSEL && PENABLE);
    endproperty

    assert property (p_setup_to_access)
        else $error("[SVA] APB SETUP was not followed by ACCESS");


    // =========================================================
    // APB SIGNAL STABILITY
    // =========================================================

    // Address must remain stable while APB waits for PREADY.
    property p_apb_addr_stable;
        (PSEL && PENABLE && !PREADY)
        |=> $stable(PADDR);
    endproperty

    assert property (p_apb_addr_stable)
        else $error("[SVA] PADDR changed while APB transfer was waiting");


    // Write control must remain stable while APB waits.
    property p_apb_write_stable;
        (PSEL && PENABLE && !PREADY)
        |=> $stable(PWRITE);
    endproperty

    assert property (p_apb_write_stable)
        else $error("[SVA] PWRITE changed while APB transfer was waiting");


    // Write data must remain stable while APB waits.
    property p_apb_wdata_stable;
        (PSEL && PENABLE && PWRITE && !PREADY)
        |=> $stable(PWDATA);
    endproperty

    assert property (p_apb_wdata_stable)
        else $error("[SVA] PWDATA changed while APB transfer was waiting");


    // =========================================================
    // APB COMPLETION
    // =========================================================

    // When APB transfer completes, the bridge must leave APB
    // access on the following clock.
    property p_apb_completion;
        (PSEL && PENABLE && PREADY)
        |=> !PSEL;
    endproperty

    assert property (p_apb_completion)
        else $error("[SVA] APB transfer did not terminate after PREADY");


    // =========================================================
    // AHB -> APB TRANSFER
    // =========================================================

    // An AHB request must generate an APB setup phase.
    property p_ahb_to_apb_setup;
        (HSEL && HRESETn) |=> (PSEL && !PENABLE);
    endproperty

    assert property (p_ahb_to_apb_setup)
        else $error("[SVA] AHB request did not generate APB SETUP");


    // =========================================================
    // AHB READY
    // =========================================================

    // When APB is inactive, the bridge should be ready for AHB.
    property p_ahb_ready_when_idle;
        (!PSEL && HRESETn) |-> HREADY;
    endproperty

    assert property (p_ahb_ready_when_idle)
        else $error("[SVA] HREADY low while APB is idle");


    // =========================================================
    // AHB / APB CONTROL CONSISTENCY
    // =========================================================

    // APB write direction must correspond to the captured AHB
    // write direction during an active transfer.
    //
    // For the current bridge architecture, once PSEL is active
    // PWRITE is the registered AHB HWRITE value.
    property p_write_control_consistency;
        PSEL |-> (PWRITE == $past(HWRITE, 1));
    endproperty

    assert property (p_write_control_consistency)
        else $error("[SVA] PWRITE does not match AHB HWRITE");


    // =========================================================
    // ERROR RESPONSE
    // =========================================================

    // Current bridge does not generate APB/AHB errors.
    // Therefore HRESP must remain LOW.
    property p_no_ahb_error;
        HRESETn |-> !HRESP;
    endproperty

    assert property (p_no_ahb_error)
        else $error("[SVA] Unexpected HRESP error asserted");


endmodule
