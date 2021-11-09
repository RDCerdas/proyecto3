
//Pruebas secuencia pruebas aleatorias
class sec_trans_aleatorias extends uvm_sequence;
    `uvm_object_utils(sec_trans_aleatorias)

    int num_transacciones = 2;

    function new(string name = "sec_trans_aleatorias");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("SEQUENCE", $sformatf("\nSec random transactions created\n %s\n", this.sprint()), UVM_HIGH)
        for(int i = 0; i<num_transacciones; i++) begin
            trans_mul item = trans_mul::type_id::create("item");
            start_item(item);
            if(!item.randomize()) begin
                `uvm_error("No randomized", $sformatf("\nUnable to randomize seq_item"));
            end
            `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
            finish_item(item);
        end
    endtask

endclass

//Pruebas con valores especificos 
class trans_especifica extends uvm_sequence;
    `uvm_object_utils_begin(trans_especifica)
        `uvm_field_int(fp_X, UVM_DEFAULT)
        `uvm_field_int(fp_Y, UVM_DEFAULT)
        `uvm_field_int(r_mode, UVM_DEFAULT)
    `uvm_object_utils_end

    bit [31:0] fp_X;
    bit [31:0] fp_Y;
    bit [2:0] r_mode;

    function new(string name = "trans_especifica");
        super.new(name);
    endfunction

    virtual task body(); 
        trans_mul item = trans_mul::type_id::create("item");
    	`uvm_info("SEQUENCE", $sformatf("\nEspecific transaction created\n %s\n", this.sprint()), UVM_HIGH)
        start_item(item);
        item.fp_X = this.fp_X;
        item.fp_y = this.fp_y;
        item.r_mode = this.r_mode;
        `uvm_info("SEQ", $sformatf("\nNew item: \n %s", item.sprint()), UVM_MEDIUM)
        finish_item(item);
    endtask

endclass