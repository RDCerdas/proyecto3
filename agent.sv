// Agente
class agent #(parameter width =16, parameter depth = 8) extends uvm_agent;
    `uvm_component_utils(agent)
    
    driver #(.width(width)) driver_inst;
    uvm_sequencer #(trans_fifo #(.width(width))) sequencer_inst;

    function new(string name = "agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
		//Driver
        driver_inst = driver::type_id::create("driver_inst", this);
		//Secuenciador
        sequencer_inst = uvm_sequencer #(trans_fifo)::type_id::create("sequencer_inst", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver_inst.seq_item_port.connect(sequencer_inst.seq_item_export);
    endfunction
endclass
