import uvm_pkg::*;

class env extends uvm_env;

    `uvm_component_utils(env)

    function new(string name = "env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
	
	//Agente
    agent agent_inst;
	//Scoreboard
    scoreboard  scoreboard_inst;
	

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent_inst = agent::type_id::create("agent_inst", this);
        scoreboard_inst = scoreboard::type_id::create("scoreboard_inst", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent_inst.driver_inst.driver_aport.connect(scoreboard_inst.m_analysis_imp);
    endfunction

endclass
