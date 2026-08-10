class ahb_write_read_seq extends ahb_base_sequence;

    `uvm_object_utils(ahb_write_read_seq)

    function new(string name = "ahb_write_read_seq");
        super.new(name);
    endfunction


    task body();

        ahb_transaction tr;

        // ==========================================
        // WRITE
        // ==========================================

        tr = ahb_transaction::type_id::create("write_tr");

        start_item(tr);

        tr.write = 1'b1;
        tr.addr  = 32'h00000008;
        tr.wdata = 32'hCAFEBABE;
        tr.burst = 3'b000;

        finish_item(tr);

        `uvm_info(
            "SEQUENCE",
            "WRITE 0xCAFEBABE -> address 0x08",
            UVM_MEDIUM
        )


        // ==========================================
        // READ
        // ==========================================

        tr = ahb_transaction::type_id::create("read_tr");

        start_item(tr);

        tr.write = 1'b0;
        tr.addr  = 32'h00000008;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;

        finish_item(tr);

        `uvm_info(
            "SEQUENCE",
            "READ from address 0x08",
            UVM_MEDIUM
        )

    endtask

endclass
