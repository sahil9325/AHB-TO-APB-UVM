class ahb_multi_write_read_seq extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_multi_write_read_seq)

    function new(string name = "ahb_multi_write_read_seq");
        super.new(name);
    endfunction

    task body();

        ahb_transaction tr;

        // ---------------------------------------------
        // WRITE 1
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("write1");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000008;
        tr.wdata = 32'hCAFEBABE;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "WRITE 1: ADDR=08 DATA=CAFEBABE",
            UVM_MEDIUM
        )

        // ---------------------------------------------
        // WRITE 2
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("write2");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h0000000C;
        tr.wdata = 32'h12345678;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "WRITE 2: ADDR=0C DATA=12345678",
            UVM_MEDIUM
        )

        // ---------------------------------------------
        // WRITE 3
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("write3");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000010;
        tr.wdata = 32'hDEADBEEF;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "WRITE 3: ADDR=10 DATA=DEADBEEF",
            UVM_MEDIUM
        )

        // ---------------------------------------------
        // READ 1
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("read1");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h00000008;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "READ 1: ADDR=08",
            UVM_MEDIUM
        )

        // ---------------------------------------------
        // READ 2
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("read2");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h0000000C;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "READ 2: ADDR=0C",
            UVM_MEDIUM
        )

        // ---------------------------------------------
        // READ 3
        // ---------------------------------------------
        tr = ahb_transaction::type_id::create("read3");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h00000010;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info(
            "MULTI_SEQ",
            "READ 3: ADDR=10",
            UVM_MEDIUM
        )

    endtask

endclass
