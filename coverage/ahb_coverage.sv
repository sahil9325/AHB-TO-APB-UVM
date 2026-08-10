class ahb_coverage extends uvm_subscriber #(ahb_transaction);

    `uvm_component_utils(ahb_coverage)

    // =========================================================
    // Coverage counters
    // =========================================================

    int read_count;
    int write_count;

    int single_count;
    int incr_count;
    int incr4_count;

    int addr_00_3f_count;
    int addr_40_7f_count;
    int addr_80_bf_count;
    int addr_c0_ff_count;

    // WRITE/READ x BURST
    int read_single_count;
    int read_incr_count;
    int read_incr4_count;

    int write_single_count;
    int write_incr_count;
    int write_incr4_count;

    // Total number of coverage bins.
    //
    // 2 operation bins
    // 3 burst bins
    // 4 address bins
    // 6 operation x burst bins
    //
    // Total = 15
    int total_bins = 15;
    int covered_bins;


    // =========================================================
    // Constructor
    // =========================================================

    function new(
        string name = "ahb_coverage",
        uvm_component parent = null
    );

        super.new(name, parent);

    endfunction


    // =========================================================
    // Sample transaction
    // =========================================================

    virtual function void write(ahb_transaction t);

        // -----------------------------------------------------
        // READ / WRITE
        // -----------------------------------------------------

        if (t.write) begin
            write_count++;
        end
        else begin
            read_count++;
        end


        // -----------------------------------------------------
        // BURST TYPE
        // -----------------------------------------------------

        case (t.burst)

            3'b000:
                single_count++;

            3'b001:
                incr_count++;

            3'b010:
                incr4_count++;

            default:
                begin
                    // Unsupported burst type.
                end

        endcase


        // -----------------------------------------------------
        // ADDRESS RANGE
        // -----------------------------------------------------

        if (t.addr >= 32'h00000000 &&
            t.addr <= 32'h0000003F) begin

            addr_00_3f_count++;

        end
        else if (t.addr >= 32'h00000040 &&
                 t.addr <= 32'h0000007F) begin

            addr_40_7f_count++;

        end
        else if (t.addr >= 32'h00000080 &&
                 t.addr <= 32'h000000BF) begin

            addr_80_bf_count++;

        end
        else if (t.addr >= 32'h000000C0 &&
                 t.addr <= 32'h000000FF) begin

            addr_c0_ff_count++;

        end


        // -----------------------------------------------------
        // READ/WRITE x BURST
        // -----------------------------------------------------

        if (!t.write) begin

            case (t.burst)

                3'b000:
                    read_single_count++;

                3'b001:
                    read_incr_count++;

                3'b010:
                    read_incr4_count++;

                default:
                    begin
                    end

            endcase

        end
        else begin

            case (t.burst)

                3'b000:
                    write_single_count++;

                3'b001:
                    write_incr_count++;

                3'b010:
                    write_incr4_count++;

                default:
                    begin
                    end

            endcase

        end

    endfunction


    // =========================================================
    // Calculate covered bins
    // =========================================================

    function void calculate_coverage();

        covered_bins = 0;


        // -----------------------------------------------------
        // READ / WRITE bins
        // -----------------------------------------------------

        if (read_count > 0)
            covered_bins++;

        if (write_count > 0)
            covered_bins++;


        // -----------------------------------------------------
        // BURST bins
        // -----------------------------------------------------

        if (single_count > 0)
            covered_bins++;

        if (incr_count > 0)
            covered_bins++;

        if (incr4_count > 0)
            covered_bins++;


        // -----------------------------------------------------
        // ADDRESS bins
        // -----------------------------------------------------

        if (addr_00_3f_count > 0)
            covered_bins++;

        if (addr_40_7f_count > 0)
            covered_bins++;

        if (addr_80_bf_count > 0)
            covered_bins++;

        if (addr_c0_ff_count > 0)
            covered_bins++;


        // -----------------------------------------------------
        // READ/WRITE x BURST
        // -----------------------------------------------------

        if (read_single_count > 0)
            covered_bins++;

        if (read_incr_count > 0)
            covered_bins++;

        if (read_incr4_count > 0)
            covered_bins++;

        if (write_single_count > 0)
            covered_bins++;

        if (write_incr_count > 0)
            covered_bins++;

        if (write_incr4_count > 0)
            covered_bins++;

    endfunction


    // =========================================================
    // Report coverage
    // =========================================================

    function void report_phase(uvm_phase phase);

        real coverage_percent;

        super.report_phase(phase);

        calculate_coverage();

        coverage_percent =
            (real'(covered_bins) / real'(total_bins)) * 100.0;


        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AHB functional coverage = %0.2f%% (%0d/%0d bins)",
                coverage_percent,
                covered_bins,
                total_bins
            ),
            UVM_LOW
        )


        // -----------------------------------------------------
        // Detailed report
        // -----------------------------------------------------

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "READ=%0d WRITE=%0d",
                read_count,
                write_count
            ),
            UVM_LOW
        )

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "SINGLE=%0d INCR=%0d INCR4=%0d",
                single_count,
                incr_count,
                incr4_count
            ),
            UVM_LOW
        )

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "ADDR[00-3F]=%0d ADDR[40-7F]=%0d ADDR[80-BF]=%0d ADDR[C0-FF]=%0d",
                addr_00_3f_count,
                addr_40_7f_count,
                addr_80_bf_count,
                addr_c0_ff_count
            ),
            UVM_LOW
        )

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "READxBURST: SINGLE=%0d INCR=%0d INCR4=%0d",
                read_single_count,
                read_incr_count,
                read_incr4_count
            ),
            UVM_LOW
        )

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "WRITExBURST: SINGLE=%0d INCR=%0d INCR4=%0d",
                write_single_count,
                write_incr_count,
                write_incr4_count
            ),
            UVM_LOW
        )

    endfunction

endclass
