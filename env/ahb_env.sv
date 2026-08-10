class ahb_env extends uvm_env;

    `uvm_component_utils(ahb_env)

    ahb_agent      agent;
    ahb_scoreboard scoreboard;

    function new(string name = "ahb_env",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = ahb_agent::type_id::create(
                    "agent",
                    this);

        scoreboard = ahb_scoreboard::type_id::create(
                        "scoreboard",
                        this);

    endfunction


    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_export
        );

    endfunction

endclass
