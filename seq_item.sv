typedef enum { lectura, escritura, reset} tipo_trans; 

class trans_mul extends uvm_sequence_item;

  `uvm_object_utils_begin(trans_mul)
    `uvm_field_int(ovrf, UVM_DEFAULT)
    `uvm_field_int(udrf, UVM_DEFAULT)
    `uvm_field_int(r_mode, UVM_DEFAULT)
    `uvm_field_int(fp_X,UVM_DEFAULT)
    `uvm_field_int(fp_Y, UVM_DEFAULT)
    `uvm_field_int(fp_Z, UVM_DEFAULT)
  `uvm_object_utils_end

  constraint caso_cero {if(fp_X[30:23]==0)
                        fp_X[22:0]==0;
                      if(fp_Y[30:23]==0)
                        fp_Y[22:0]==0;}

  constraint inf_nan {if(fp_X[30:23]==8'hFF){ 
                        fp_X[22] inside {0, 1};
                        fp_X[21:0] == '0;
		    }
                    if(fp_Y[30:23]==8'hFF) {
                       fp_Y[22] inside {0, 1};
                       fp_Y[21:0] == '0;
	       }}
  
  constraint modo {r_mode inside {[0:4]};}
  
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
