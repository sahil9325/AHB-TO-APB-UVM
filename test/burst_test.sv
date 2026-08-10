class burst_test extends base_test;

    `uvm_component_utils(burst_test)

    function new(
        string name = "burst_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);

        ahb_burst_seq seq;

        phase.raise_objection(this);

        `uvm_info(
            "TEST",
            "Starting AHB INCR burst test",
            UVM_MEDIUM
        )

        seq = ahb_burst_seq::type_id::create("seq");

        seq.start(env.agent.sequencer);

        `uvm_info(
            "TEST",
            "AHB INCR burst test completed",
            UVM_MEDIUM
        )

        phase.drop_objection(this);

    endtask

endclass
