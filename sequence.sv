// Transaccion aleatorias
class trans_aleatoria extends uvm_sequence;
    `uvm_object_utils_begin(trans_aleatoria)
        `uvm_field_int(max_retardo, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end

    int max_retardo = 10;

    function new(string name = "trans_aleatoria");
        super.new(name);
    endfunction

    virtual task body();
        trans_fifo item = trans_fifo::type_id::create("item");	
        `uvm_info("SEQUENCE", $sformatf("\nRandom transaction created\n %s\n", this.sprint()), UVM_HIGH)
        start_item(item);
        if(!item.randomize()) begin
            `uvm_error("No randomized", $sformatf("\nUnable to randomize seq_item"));
        end
        item.max_retardo = max_retardo;
        `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
        finish_item(item);
    endtask

endclass

// Secuencia de transacciones aleatorias
class sec_trans_aleatorias extends uvm_sequence;
    `uvm_object_utils_begin(sec_trans_aleatorias)
        `uvm_field_int(num_transacciones, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(max_retardo, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end

    int num_transacciones = 2;
    int max_retardo = 10;

    function new(string name = "sec_trans_aleatorias");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("SEQUENCE", $sformatf("\nSec random transactions created\n %s\n", this.sprint()), UVM_HIGH)
        for(int i = 0; i<num_transacciones; i++) begin
            trans_fifo item = trans_fifo::type_id::create("item");
            start_item(item);
            if(!item.randomize()) begin
                `uvm_error("No randomized", $sformatf("\nUnable to randomize seq_item"));
            end
            item.max_retardo = max_retardo;
            `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
    endtask

endclass

// Transaccion especifica
class trans_especifica extends uvm_sequence;
    `uvm_object_utils_begin(trans_especifica)
        `uvm_field_int(dto_spec, UVM_DEFAULT)
        `uvm_field_enum(tipo_trans, tpo_spec, UVM_DEFAULT)
        `uvm_field_int(ret_spec, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end

    tipo_trans tpo_spec;
    bit [width-1:0] dto_spec;
    int ret_spec = 2;

    function new(string name = "trans_especifica");
        super.new(name);
    endfunction

    virtual task body(); 
        trans_fifo item = trans_fifo::type_id::create("item");
    	`uvm_info("SEQUENCE", $sformatf("\nEspecific transaction created\n %s\n", this.sprint()), UVM_HIGH)
        start_item(item);
        item.tipo = this.tpo_spec;
        item.dato = this.dto_spec;
        item.retardo = this.ret_spec;
        `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
        finish_item(item);
    endtask

endclass

// Transacción de llenado aleatorio
class llenado_aleatorio extends uvm_sequence;
    `uvm_object_utils_begin(llenado_aleatorio)
        `uvm_field_enum(tipo_trans, tpo_spec, UVM_DEFAULT)
        `uvm_field_int(dto_spec, UVM_DEFAULT)
        `uvm_field_int(ret_spec, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(num_transacciones, UVM_DEFAULT|UVM_DEC)
        `uvm_field_int(max_retardo, UVM_DEFAULT|UVM_DEC)
    `uvm_object_utils_end

    int num_transacciones = 2;
    tipo_trans tpo_spec;
    bit [width-1:0] dto_spec;
    int ret_spec = 2;
    int max_retardo = 10;

    function new(string name = "llenado_aleatorio");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("SEQUENCE", $sformatf("\nLlenado aleatorio creado\n %s\n", this.sprint()), UVM_HIGH)
        // Primero se crean transacciones de escritura
        for(int i = 0; i<num_transacciones; i++) begin
            trans_fifo item = trans_fifo::type_id::create("item");
            start_item(item);
            item.max_retardo = max_retardo;
            if(!item.randomize()) begin
                `uvm_error("No randomized", $sformatf("\Unable to randomize seq_item"));
            end
            item.tipo = escritura;
            item.retardo = this.ret_spec;
            `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
        // Se crean transacciones de lectura
        for(int i = 0; i<num_transacciones; i++) begin
            trans_fifo item = trans_fifo::type_id::create("item");
            start_item(item);
            if(!item.randomize()) begin
                `uvm_error("No randomized", $sformatf("\Unable to randomize seq_item"));
            end
            item.tipo = lectura;
            `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
    endtask

endclass
