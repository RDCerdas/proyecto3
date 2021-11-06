// Driver
class driver #(parameter width =16) extends uvm_driver #(trans_fifo); //fixme
    `uvm_component_utils(driver)

    uvm_analysis_port #(trans_fifo) driver_aport; //fixme

    virtual mult_if vif;

    function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual mult_if)::get(this, "", "_if", vif))
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

            // Se extrae nuevo item y se espera a flanco de reloj
            seq_item_port.get_next_item(item);
            @(posedge vif.clk);

            `uvm_info("DRIVER", $sformatf("\nItem receive \n %s", item.sprint()), UVM_HIGH)
            driver_item(item);

            // Se espera al resultado
            @(posedge vif.clk);
            // Se envía el resultado al scoreboard
            get_result(item);

	        seq_item_port.item_done();

        end
    endtask
	
	// Funcion para realizar acciones con cada dato
    virtual task driver_item( item);//fixme
        vif.r_mode = item.r_mode;
        vif.fp_X = item.fp_X;
    endtask

    // Funcion para almacenar resultado en item y enviarlo a scoreboard
    virtual task get_result( item);//fixme
        item.fp_Z = vif.fp_Z;
        item.ovrf = vif.ovrf;
        item.udrf = vif.udrf;
        driver_aport.write(item);
        `uvm_info("DRIVER", $sformatf("\nItem send to checker \n %s", item.sprint()), UVM_DEBUG)
    endtask
endclass
