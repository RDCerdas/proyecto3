typedef enum { lectura, escritura, reset} tipo_trans; 


class trans_fifo #(parameter width = 16) extends uvm_sequence_item;

  `uvm_object_utils_begin(trans_fifo)
    `uvm_field_int(retardo, UVM_DEFAULT|UVM_DEC)
    `uvm_field_enum(tipo_trans, tipo, UVM_DEFAULT)
	  `uvm_field_int(dato, UVM_DEFAULT)
    `uvm_field_int(tiempo, UVM_DEFAULT|UVM_DEC)
  `uvm_object_utils_end

  rand int retardo = 0; // tiempo de retardo en ciclos de reloj que se debe esperar antes de ejecutar la transacción
  rand bit[width-1:0] dato = 0; // este es el dato de la transacción
  int tiempo = 0; //Representa el tiempo  de la simulación en el que se ejecutó la transacción 
  rand tipo_trans tipo = lectura; // lectura, escritura, reset;
  int max_retardo = 10;
  
  constraint const_retardo {retardo < max_retardo; retardo>0;}

  function new(string name = "trans_fifo");
      super.new(name);
  endfunction 
endclass

class trans_sb #(parameter width=16) extends uvm_object;
  `uvm_object_utils_begin(trans_sb)
    `uvm_field_int(dato_enviado, UVM_DEFAULT)
    `uvm_field_int(tiempo_push, UVM_DEFAULT|UVM_DEC)
    `uvm_field_int(tiempo_pop, UVM_DEFAULT|UVM_DEC)
    `uvm_field_int(completado, UVM_DEFAULT)
    `uvm_field_int(overflow, UVM_DEFAULT)
    `uvm_field_int(underflow, UVM_DEFAULT)
    `uvm_field_int(reset, UVM_DEFAULT)
    `uvm_field_int(latencia, UVM_DEFAULT|UVM_DEC)
  `uvm_object_utils_end

  function new(string name = "trans_sb");
      super.new(name);
  endfunction 

  bit [width-1:0] dato_enviado;
  int tiempo_push;
  int tiempo_pop;
  bit completado;
  bit overflow;
  bit underflow;
  bit reset;
  int latencia;
  
  function clean();
    this.dato_enviado = 0;
    this.tiempo_push = 0;
    this.tiempo_pop = 0;
    this.completado = 0;
    this.overflow = 0;
    this.underflow = 0;
    this.reset = 0;
    this.latencia = 0;
  endfunction

  task calc_latencia;
    this.latencia = this.tiempo_pop - this.tiempo_push;
  endtask
endclass
