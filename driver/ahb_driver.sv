class ahb_driver extends uvm_driver #(ahb_transaction);

    `uvm_component_utils(ahb_driver)

    virtual ahb_if vif;

    function new(string name = "ahb_driver",
                 uvm_component parent = null);
        super.new(name, parent);
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

        // Initialize the bus before accepting the first item.
        vif.HSEL   <= 1'b0;
        vif.HWRITE <= 1'b0;
        vif.HADDR  <= 32'h0;
        vif.HWDATA <= 32'h0;
        vif.HBURST <= 3'b000;
        
        wait (vif.HRESETn === 1'b1);
        @(posedge vif.HCLK);
        
        forever begin

            seq_item_port.get_next_item(tr);

            drive_transaction(tr);

            seq_item_port.item_done();

        end

    endtask


    task drive_transaction(ahb_transaction tr);

        // =================================================
        // DRIVE AHB REQUEST
        // =================================================
        @(posedge vif.HCLK);

        vif.HSEL   <= 1'b1;
        vif.HWRITE <= tr.write;
        vif.HADDR  <= tr.addr;
        vif.HWDATA <= tr.wdata;
        vif.HBURST <= tr.burst;

        `uvm_info(
            "AHB_DRIVER",
            $sformatf(
                "Driving: WRITE=%0b ADDR=%08h WDATA=%08h BURST=%03b",
                tr.write,
                tr.addr,
                tr.wdata,
                tr.burst
            ),
            UVM_MEDIUM
        )

        // =================================================
        // HOLD AHB REQUEST FOR ONE CLOCK
        //
        // At this edge the bridge captures the request and
        // enters SETUP. HREADY becomes LOW.
        // =================================================
        @(posedge vif.HCLK);

        vif.HSEL <= 1'b0;

        // =================================================
        // DO NOT WAIT FOR HREADY TO GO LOW HERE.
        //
        // The bridge's SETUP state already guarantees one
        // cycle with HREADY=0. Instead, wait for the next
        // HCLK edges until HREADY becomes HIGH.
        // =================================================

        do begin
            @(posedge vif.HCLK);
        end while (vif.HREADY !== 1'b1);

        // =================================================
        // TRANSACTION COMPLETE
        // =================================================
        tr.rdata = vif.HRDATA;
        tr.ready = vif.HREADY;
        tr.resp  = vif.HRESP;

        `uvm_info(
            "AHB_DRIVER",
            $sformatf(
                "Transaction completed: WRITE=%0b ADDR=%08h WDATA=%08h RDATA=%08h RESP=%0b HREADY=%0b",
                tr.write,
                tr.addr,
                tr.wdata,
                tr.rdata,
                tr.resp,
                tr.ready
            ),
            UVM_MEDIUM
        )

    endtask

endclass
