class write_read_test extends base_test;

    `uvm_component_utils(write_read_test)

    function new(string name = "write_read_test",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    task run_phase(uvm_phase phase);

        ahb_write_read_seq seq;

        phase.raise_objection(this);

        `uvm_info(
            "TEST",
            "Starting AHB-to-APB WRITE/READ test",
            UVM_LOW
        )

        seq = ahb_write_read_seq::type_id::create(
                    "seq");

        seq.start(env.agent.sequencer);

        `uvm_info(
            "TEST",
            "AHB-to-APB WRITE/READ test completed",
            UVM_LOW
        )

        phase.drop_objection(this);

    endtask

endclass
