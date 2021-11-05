// Driver
class driver #(parameter width =16) extends uvm_driver #(trans_fifo);
    `uvm_component_utils(driver)
    
    int espera;

    uvm_analysis_port #(trans_fifo #(.width(width))) driver_aport;

    virtual fifo_if #(.width(width)) vif;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual fifo_if)::get(this, "", "_if", vif))
            `uvm_fatal("Driver", "Could not get vif")
    	driver_aport = new("driver_aport", this);
    endfunction
	
	// Cada transaccion que recibe
    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
            @(posedge vif.clk);
        vif.rst=1;
        // Logica que corre continuamente
        @(posedge vif.clk);
        forever begin
            trans_fifo #(.width(width)) item;
            vif.push = 0;
            vif.rst = 0;
            vif.pop = 0;
            vif.dato_in = 0;
            espera = 0;
            @(posedge vif.clk);
            // Se extrae nuevo item
            seq_item_port.get_next_item(item);
            `uvm_info("DRIVER", $sformatf("\nItem receive \n %s", item.sprint()), UVM_HIGH)
           driver_item(item);
	        seq_item_port.item_done();

        end
    endtask
	
	// Funcion para realizar acciones con cada dato
    virtual task driver_item(trans_fifo #(.width(width)) transaction);
        while(this.espera < transaction.retardo)begin
          @(posedge vif.clk);
          this.espera = this.espera+1;
          vif.dato_in = transaction.dato;
	end
        // Case tomado de archivo original
        case(transaction.tipo)
	  lectura: begin
	     transaction.dato = vif.dato_out;
	     transaction.tiempo = $time;
	     @(posedge vif.clk);
	     vif.pop = 1;
	     driver_aport.write(transaction);
         `uvm_info("DRIVER", $sformatf("\nItem send to scoreboard \n %s", transaction.sprint()), UVM_HIGH)
	   end
	   escritura: begin
	     vif.push = 1;
	     transaction.tiempo = $time;
	     driver_aport.write(transaction);
         `uvm_info("DRIVER", $sformatf("\nItem send to scoreboard \n %s", transaction.sprint()), UVM_HIGH)
	   end
	   reset: begin
	     vif.rst =1;
	     transaction.tiempo = $time;
	     driver_aport.write(transaction);
         `uvm_info("DRIVER", $sformatf("\nItem send to scoreboard \n %s", transaction.sprint()), UVM_HIGH) 
	   end
	  default: begin
		`uvm_error("DRIVER", "Wrong type transaction")
		$finish;

	     end 
	    endcase    
	    @(posedge vif.clk);
    endtask
endclass
