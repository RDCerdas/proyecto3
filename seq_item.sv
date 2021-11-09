typedef enum { lectura, escritura, reset} tipo_trans; 

class trans_mul extends uvm_sequence_item;

  `uvm_object_utils_begin(trans_mul)
    `uvm_field_int(ovrf, UVM_DEFAULT)
    `uvm_field_int(udrf, UVM_DEFAULT)
	  `uvm_field_int(r_mode, UVM_DEFAULT)
    `uvm_field_int(fp_X, UVM_DEFAULT)
    `uvm_field_int(fp_Y, UVM_DEFAULT)
    `uvm_field_int(fp_Z, UVM_DEFAULT)
  `uvm_object_utils_end

  rand bit [2:0] r_mode;
  rand bit [31:0] fp_X;
  rand bit [31:0] fp_Y;
  bit [31:0] fp_Z;
  bit ovrf;
  bit udrf;

  function new(string name = "trans_mul");
      super.new(name);
  endfunction 
endclass
