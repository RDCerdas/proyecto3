import uvm_pkg::*;

// Test base con la configuración de environment y la interfaz
class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env #(.width(width),.depth(depth)) e0;
    virtual fifo_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env#(.width(width),.depth(depth))::type_id::create("e0", this);
		// Se toma interfaz
        if(!uvm_config_db#(virtual fifo_if)::get(this, "", "_if", vif))
            `uvm_fatal("Test", "Could not get vif")

        uvm_config_db#(virtual fifo_if)::set(this, "e0.agent_inst.*", "_if", vif);
    endfunction
endclass

// Test que hereda del base con transacciones específicas
class test_especifico extends base_test;
    `uvm_component_utils(test_especifico)

    int width = 16;

    function new(string name = "test_especifico", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans_especifica trans_especifica_inst = trans_especifica::type_id::create("trans_especifica_inst");

        `uvm_info("ESPECIFIC TEST", $sformatf("\n Especific test started\n"), UVM_HIGH)

        phase.raise_objection(this);

        trans_especifica_inst.ret_spec = 3;
        trans_especifica_inst.dto_spec = 'h55;
        trans_especifica_inst.tpo_spec = escritura;
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);
        
        trans_especifica_inst.ret_spec = 8;
        trans_especifica_inst.dto_spec = 16'hA;
        trans_especifica_inst.tpo_spec = escritura;
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        trans_especifica_inst.ret_spec = 10;
        trans_especifica_inst.dto_spec = 16'hFF;
        trans_especifica_inst.tpo_spec = escritura;
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        trans_especifica_inst.ret_spec = 10;
        trans_especifica_inst.tpo_spec = lectura;
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        #1000;
        phase.drop_objection(this);
endtask
endclass

// Test que hereda del base con las transacciones originales
class test_normal extends base_test;
    `uvm_component_utils(test_normal)

    int width = 16;

    function new(string name = "test_normal", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        llenado_aleatorio llenado_aleatorio_inst = llenado_aleatorio::type_id::create("llenado_aleatorio_inst");
        trans_aleatoria trans_aleatoria_inst = trans_aleatoria::type_id::create("trans_aleatoria_inst");
        trans_especifica trans_especifica_inst = trans_especifica::type_id::create("trans_especifica_inst");
        sec_trans_aleatorias sec_trans_aleatorias_inst = sec_trans_aleatorias::type_id::create("sec_trans_aleatorias_inst");

        `uvm_info("NORMAL TEST", $sformatf("\n Normal test started\n"), UVM_HIGH)

        phase.raise_objection(this);

        // Llenado aleatorio
        llenado_aleatorio_inst.start(e0.agent_inst.sequencer_inst);

        // Transacción aleatoria
        trans_aleatoria_inst.start(e0.agent_inst.sequencer_inst);

        // Escritura de 0x5
        trans_especifica_inst.ret_spec = 3;
        trans_especifica_inst.tpo_spec = escritura;
        trans_especifica_inst.dto_spec = 'h5;
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        sec_trans_aleatorias_inst.start(e0.agent_inst.sequencer_inst);
        #1000;
        phase.drop_objection(this);
    endtask
endclass
