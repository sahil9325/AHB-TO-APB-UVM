class coverage_test extends base_test;

    `uvm_component_utils(coverage_test)

    function new(
        string name = "coverage_test",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    task run_phase(uvm_phase phase);

        ahb_coverage_seq seq;

        phase.raise_objection(this);

        `uvm_info(
            "TEST",
            "Starting AHB functional coverage closure test",
            UVM_MEDIUM
        )

        seq = ahb_coverage_seq::type_id::create("seq");

        seq.start(env.agent.sequencer);

        `uvm_info(
            "TEST",
            "AHB functional coverage closure test completed",
            UVM_MEDIUM
        )

        phase.drop_objection(this);

    endtask

endclass
