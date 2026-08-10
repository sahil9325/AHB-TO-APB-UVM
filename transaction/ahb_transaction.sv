class ahb_transaction extends uvm_sequence_item;

        rand bit        write;
        rand bit [31:0] addr;
        rand bit [31:0] wdata;
        rand bit [2:0]  burst;

        bit [31:0] rdata;
        bit        ready;
        bit        resp;

        constraint burst_c {
            burst inside {3'b000, 3'b001, 3'b010};
        }

        `uvm_object_utils(ahb_transaction)

        function new(string name = "ahb_transaction");
            super.new(name);
        endfunction

    endclass

