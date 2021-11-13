import uvm_pkg::*;

// Test base con la configuración de environment y la interfaz
class base_test extends uvm_test;
    `uvm_component_utils(base_test)

    function new(string name = "test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    env e0;
    virtual mult_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e0 = env::type_id::create("e0", this);
		// Se toma interfaz
        if(!uvm_config_db#(virtual mult_if)::get(this, "", "_if", vif))
            `uvm_fatal("Test", "Could not get vif")

        uvm_config_db#(virtual mult_if)::set(this, "e0.agent_inst.*", "_if", vif);
    endfunction
endclass

// Test que hereda del base con transacciones específicas
class random_test extends base_test;
    `uvm_component_utils(random_test)

    function new(string name = "random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        sec_trans_aleatorias trans_aleatoria_inst = sec_trans_aleatorias::type_id::create("trans_aleatoria_inst");

        `uvm_info("RANDOM TEST", $sformatf("\n Random test started\n"), UVM_HIGH)

        phase.raise_objection(this);

        trans_aleatoria_inst.num_transacciones = 1000;
        trans_aleatoria_inst.start(e0.agent_inst.sequencer_inst);

        #500;
        phase.drop_objection(this);
endtask
endclass

class test_especifico extends base_test;
    `uvm_component_utils(test_especifico)

    function new(string name = "test_especifico", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
    endfunction

    virtual task run_phase(uvm_phase phase);
        trans_especifica trans_especifica_inst = trans_especifica::type_id::create("trans_especifica_inst");

        `uvm_info("Specific test", $sformatf("\n Specific test started\n"), UVM_HIGH)

        phase.raise_objection(this);
        //zeroxzero
        trans_especifica_inst.fp_X = 0; 
        trans_especifica_inst.fp_Y = 0;
        trans_especifica_inst.r_mode =       
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);
        //zeroxnan
        trans_especifica_inst.fp_X = 0; 
        trans_especifica_inst.fp_Y = 32'h7FC00000; //nan  
        trans_especifica_inst.r_mode =         
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);
        //zeroxinf
        trans_especifica_inst.fp_X = 0; 
        trans_especifica_inst.fp_Y = 32'h7F800000; //infinito
        trans_especifica_inst.r_mode =         
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);
        //infxinf
        trans_especifica_inst.fp_X = 32'h7F800000; //infinito
        trans_especifica_inst.fp_Y = 32'h7F800000; //infinito
        trans_especifica_inst.r_mode =          
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);
        //infxnan
        trans_especifica_inst.fp_X = 32'h7F800000; //infinito 
        trans_especifica_inst.fp_Y = 32'h7FC00000; //nan  
        trans_especifica_inst.r_mode =          
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        //nanxnan
        trans_especifica_inst.fp_X = 32'h7FC00000; //nan 
        trans_especifica_inst.fp_Y = 32'h7FC00000; //nan  
        trans_especifica_inst.r_mode =          
        trans_especifica_inst.start(e0.agent_inst.sequencer_inst);

        #500;
        phase.drop_objection(this);
endtask
endclass



