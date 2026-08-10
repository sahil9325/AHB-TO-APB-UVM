class ahb_coverage extends uvm_subscriber #(ahb_transaction);

    `uvm_component_utils(ahb_coverage)

    // -------------------------------------------------
    // Sampled transaction fields
    // -------------------------------------------------

    bit        cov_write;
    bit [2:0]  cov_burst;
    bit [31:0] cov_addr;

    // -------------------------------------------------
    // Functional coverage
    // -------------------------------------------------

    covergroup ahb_cg;

        // -------------------------------------------------
        // WRITE / READ coverage
        // -------------------------------------------------

        cp_write: coverpoint cov_write {
            bins READ  = {1'b0};
            bins WRITE = {1'b1};
        }

        // -------------------------------------------------
        // Burst type coverage
        // -------------------------------------------------

        cp_burst: coverpoint cov_burst {
            bins SINGLE = {3'b000};
            bins INCR   = {3'b001};
            bins INCR4  = {3'b010};
        }

        // -------------------------------------------------
        // Address range coverage
        // -------------------------------------------------

        cp_addr: coverpoint cov_addr {
            bins ADDR_00_3F = {[32'h00000000:32'h0000003F]};
            bins ADDR_40_7F = {[32'h00000040:32'h0000007F]};
            bins ADDR_80_BF = {[32'h00000080:32'h000000BF]};
            bins ADDR_C0_FF = {[32'h000000C0:32'h000000FF]};
        }

        // -------------------------------------------------
        // WRITE/READ × BURST cross coverage
        // -------------------------------------------------

        write_burst: cross cp_write, cp_burst;

    endgroup


    // -------------------------------------------------
    // Constructor
    // -------------------------------------------------

    function new(
        string name = "ahb_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

        ahb_cg = new();

    endfunction


    // -------------------------------------------------
    // Receive transaction from monitor
    // -------------------------------------------------

    virtual function void write(ahb_transaction t);

        cov_write = t.write;
        cov_burst = t.burst;
        cov_addr  = t.addr;

        ahb_cg.sample();

    endfunction


    // -------------------------------------------------
    // Coverage report
    // -------------------------------------------------

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AHB functional coverage = %0.2f%%",
                ahb_cg.get_coverage()
            ),
            UVM_LOW
        )

    endfunction

endclass
