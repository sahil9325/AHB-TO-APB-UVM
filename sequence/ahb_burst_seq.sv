class ahb_burst_seq extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_burst_seq)

    function new(string name = "ahb_burst_seq");
        super.new(name);
    endfunction

    task body();

        ahb_transaction tr;

        bit [31:0] addresses [4];
        bit [31:0] data [4];

        addresses[0] = 32'h00000020;
        addresses[1] = 32'h00000024;
        addresses[2] = 32'h00000028;
        addresses[3] = 32'h0000002C;

        data[0] = 32'h11111111;
        data[1] = 32'h22222222;
        data[2] = 32'h33333333;
        data[3] = 32'h44444444;

        // -------------------------------------------------
        // BURST WRITE
        // -------------------------------------------------

        for (int i = 0; i < 4; i++) begin

            tr = ahb_transaction::type_id::create(
                $sformatf("burst_write_%0d", i)
            );

            start_item(tr);

            tr.write = 1'b1;
            tr.addr  = addresses[i];
            tr.wdata = data[i];
            tr.burst = 3'b001;       // INCR

            finish_item(tr);

            `uvm_info(
                "BURST_SEQ",
                $sformatf(
                    "BURST WRITE: ADDR=%08h DATA=%08h BURST=INCR",
                    tr.addr,
                    tr.wdata
                ),
                UVM_MEDIUM
            );

        end

        // -------------------------------------------------
        // BURST READ
        // -------------------------------------------------

        for (int i = 0; i < 4; i++) begin

            tr = ahb_transaction::type_id::create(
                $sformatf("burst_read_%0d", i)
            );

            start_item(tr);

            tr.write = 1'b0;
            tr.addr  = addresses[i];
            tr.wdata = 32'h00000000;
            tr.burst = 3'b001;       // INCR

            finish_item(tr);

            `uvm_info(
                "BURST_SEQ",
                $sformatf(
                    "BURST READ: ADDR=%08h BURST=INCR",
                    tr.addr
                ),
                UVM_MEDIUM
            );

        end

    endtask

endclass
