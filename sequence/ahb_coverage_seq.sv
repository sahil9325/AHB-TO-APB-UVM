class ahb_coverage_seq extends uvm_sequence #(ahb_transaction);

    `uvm_object_utils(ahb_coverage_seq)

    function new(string name = "ahb_coverage_seq");
        super.new(name);
    endfunction

    task body();

        ahb_transaction tr;

        // =====================================================
        // WRITE SINGLE - 0x20
        // Covers WRITE + SINGLE + ADDR[00-3F]
        // =====================================================

        tr = ahb_transaction::type_id::create("write_single_20");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000020;
        tr.wdata = 32'h20202020;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "WRITE SINGLE @ 0x20 - ADDR[00-3F]",
            UVM_MEDIUM)


        // =====================================================
        // WRITE SINGLE - 0x40
        // Initialize 0x40 BEFORE READ
        // Covers WRITE + SINGLE + ADDR[40-7F]
        // =====================================================

        tr = ahb_transaction::type_id::create("write_single_40");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000040;
        tr.wdata = 32'h40404040;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "WRITE SINGLE @ 0x40",
            UVM_MEDIUM)


        // =====================================================
        // READ SINGLE - 0x40
        // Now initialized
        // Covers READ + SINGLE + ADDR[40-7F]
        // =====================================================

        tr = ahb_transaction::type_id::create("read_single_40");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h00000040;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "READ SINGLE @ 0x40",
            UVM_MEDIUM)


        // =====================================================
        // WRITE SINGLE - 0x80
        // Covers WRITE + SINGLE + ADDR[80-BF]
        // =====================================================

        tr = ahb_transaction::type_id::create("write_single_80");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000080;
        tr.wdata = 32'h80808080;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "WRITE SINGLE @ 0x80",
            UVM_MEDIUM)


        // =====================================================
        // WRITE INCR - 0x40
        // Covers WRITE + INCR
        // =====================================================

        tr = ahb_transaction::type_id::create("write_incr_40");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h00000040;
        tr.wdata = 32'h40404040;
        tr.burst = 3'b001;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "WRITE INCR @ 0x40",
            UVM_MEDIUM)


        // =====================================================
        // WRITE INCR4 - 0xC0
        // Initialize 0xC0 BEFORE READ
        // Covers WRITE + INCR4 + ADDR[C0-FF]
        // =====================================================

        tr = ahb_transaction::type_id::create("write_incr4_c0");

        start_item(tr);
        tr.write = 1'b1;
        tr.addr  = 32'h000000C0;
        tr.wdata = 32'hC0C0C0C0;
        tr.burst = 3'b010;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "WRITE INCR4 @ 0xC0",
            UVM_MEDIUM)


        // =====================================================
        // READ INCR - 0xC0
        // Now initialized
        // Covers READ + INCR + ADDR[C0-FF]
        // =====================================================

        tr = ahb_transaction::type_id::create("read_incr_c0");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h000000C0;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b001;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "READ INCR @ 0xC0",
            UVM_MEDIUM)


        // =====================================================
        // READ INCR4 - 0x80
        // Covers READ + INCR4 + ADDR[80-BF]
        // =====================================================

        tr = ahb_transaction::type_id::create("read_incr4_80");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h00000080;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b010;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "READ INCR4 @ 0x80",
            UVM_MEDIUM)


        // =====================================================
        // FINAL READ CHECK - 0x40
        // =====================================================

        tr = ahb_transaction::type_id::create("read_single_40_check");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h00000040;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b000;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "READ SINGLE @ 0x40 - CHECK",
            UVM_MEDIUM)


        // =====================================================
        // FINAL READ CHECK - 0xC0
        // =====================================================

        tr = ahb_transaction::type_id::create("read_incr_c0_check");

        start_item(tr);
        tr.write = 1'b0;
        tr.addr  = 32'h000000C0;
        tr.wdata = 32'h00000000;
        tr.burst = 3'b001;
        finish_item(tr);

        `uvm_info("COV_SEQ",
            "READ INCR @ 0xC0 - CHECK",
            UVM_MEDIUM)

    endtask

endclass
