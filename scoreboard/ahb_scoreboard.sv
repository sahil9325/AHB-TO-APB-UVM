class ahb_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(ahb_scoreboard)

    // Transactions arrive from the monitor
    uvm_analysis_imp #(ahb_transaction, ahb_scoreboard) analysis_export;

    // Simple reference memory
    bit [31:0] expected_mem [bit [31:0]];

    function new(string name = "ahb_scoreboard",
                 uvm_component parent = null);

        super.new(name, parent);

        analysis_export = new("analysis_export", this);

    endfunction


    function void write(ahb_transaction tr);

        // ---------------------------------------------
        // WRITE
        // ---------------------------------------------

        if (tr.write) begin

            expected_mem[tr.addr] = tr.wdata;

            `uvm_info(
                "SCOREBOARD",
                $sformatf(
                "WRITE: ADDR=%08h DATA=%08h",
                tr.addr,
                tr.wdata),
                UVM_MEDIUM
            )

        end

        // ---------------------------------------------
        // READ
        // ---------------------------------------------

        else begin

            if (expected_mem.exists(tr.addr)) begin

                if (tr.rdata === expected_mem[tr.addr]) begin

                    `uvm_info(
                        "SCOREBOARD",
                        $sformatf(
                        "READ PASS: ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                        tr.addr,
                        expected_mem[tr.addr],
                        tr.rdata),
                        UVM_MEDIUM
                    )

                end
                else begin

                    `uvm_error(
                        "SCOREBOARD",
                        $sformatf(
                        "READ FAIL: ADDR=%08h EXPECTED=%08h ACTUAL=%08h",
                        tr.addr,
                        expected_mem[tr.addr],
                        tr.rdata)
                    )

                end

            end
            else begin

                `uvm_warning(
                    "SCOREBOARD",
                    $sformatf(
                    "READ from uninitialized address %08h",
                    tr.addr)
                )

            end

        end

    endfunction

endclass
