class ahb_env extends uvm_env;

    `uvm_component_utils(ahb_env)

    ahb_agent      agent;
    ahb_scoreboard scoreboard;
    ahb_coverage   coverage;

    function new(
        string name = "ahb_env",
        uvm_component parent = null
    );
        super.new(name, parent);
    endfunction


    // =========================================================
    // BUILD
    // =========================================================

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = ahb_agent::type_id::create(
            "agent",
            this
        );

        scoreboard = ahb_scoreboard::type_id::create(
            "scoreboard",
            this
        );

        coverage = ahb_coverage::type_id::create(
            "coverage",
            this
        );

    endfunction


    // =========================================================
    // CONNECT
    // =========================================================

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        // Monitor -> Scoreboard
        agent.monitor.analysis_port.connect(
            scoreboard.analysis_export
        );

        // Monitor -> Functional Coverage
        agent.monitor.analysis_port.connect(
            coverage.analysis_export
        );

    endfunction

endclass
