class ahb_monitor extends uvm_monitor;

    `uvm_component_utils(ahb_monitor)

    virtual ahb_if vif;

    uvm_analysis_port #(ahb_transaction) analysis_port;


    function new(string name = "ahb_monitor",
                 uvm_component parent = null);

        super.new(name, parent);

        analysis_port = new(
            "analysis_port",
            this
        );

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if (!uvm_config_db#(virtual ahb_if)::get(
                this,
                "",
                "vif",
                vif)) begin

            `uvm_fatal(
                "NOVIF",
                "AHB virtual interface not found"
            )

        end

    endfunction


    task run_phase(uvm_phase phase);

    ahb_transaction tr;

    forever begin

        // Wait for a new AHB transfer
        @(posedge vif.HCLK);

        if (vif.HSEL) begin

            tr = ahb_transaction::type_id::create("tr");

            // Capture request information
            tr.write = vif.HWRITE;
            tr.addr  = vif.HADDR;
            tr.wdata = vif.HWDATA;
            tr.burst = vif.HBURST;

            // -------------------------------------------------
            // Wait until the AHB transaction actually completes
            // -------------------------------------------------
            do begin
                @(posedge vif.HCLK);
            end while (vif.HREADY !== 1'b1);

            // -------------------------------------------------
            // Now capture response information
            // -------------------------------------------------
            tr.rdata = vif.HRDATA;
            tr.ready = vif.HREADY;
            tr.resp  = vif.HRESP;

            `uvm_info(
                "AHB_MONITOR",
                $sformatf(
                    "Observed AHB: WRITE=%0b ADDR=%08h WDATA=%08h RDATA=%08h BURST=%03b RESP=%0b",
                    tr.write,
                    tr.addr,
                    tr.wdata,
                    tr.rdata,
                    tr.burst,
                    tr.resp
                ),
                UVM_MEDIUM
            )

            analysis_port.write(tr);

        end

    end

endtask

endclass
