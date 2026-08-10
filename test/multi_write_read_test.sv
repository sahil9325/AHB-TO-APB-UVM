class multi_write_read_test extends base_test;

    `uvm_component_utils(multi_write_read_test)

    function new(
        string name = "multi_write_read_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        ahb_multi_write_read_seq seq;

        phase.raise_objection(this);

        `uvm_info(
            "TEST",
            "Starting MULTIPLE WRITE/READ test",
            UVM_MEDIUM
        )

        seq = ahb_multi_write_read_seq::type_id::create("seq");

        seq.start(env.agent.sequencer);

        `uvm_info(
            "TEST",
            "MULTIPLE WRITE/READ test completed",
            UVM_MEDIUM
        )

        phase.drop_objection(this);

    endtask

endclass
