// Driver
class driver extends uvm_driver #(trans_mul);
    `uvm_component_utils(driver)
    
    // Puerto para enviar transacciones al scoreboard
    uvm_analysis_port #(trans_mul) driver_aport;

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
        // Logica que corre continuamente

        forever begin
            trans_mul item;

            // Se extrae nuevo item y se espera a flanco de reloj
            seq_item_port.get_next_item(item);

            // Wait for delay clock cicles
            repeat(item.delay) @(posedge vif.clk);

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
    virtual task driver_item(trans_mul item);
        vif.r_mode = item.r_mode;
        vif.fp_X = item.fp_X;
	vif.fp_Y = item.fp_Y;
    endtask

    // Funcion para almacenar resultado en item y enviarlo a scoreboard
    virtual task get_result(trans_mul item);
    	// Se leen todos los resultados y se obtiene el tiempo
        item.fp_Z = vif.fp_Z;
        item.ovrf = vif.ovrf;
        item.udrf = vif.udrf;
        item.m_time = $time;
        driver_aport.write(item);
        `uvm_info("DRIVER", $sformatf("\nItem send to checker \n %s", item.sprint()), UVM_DEBUG)
    endtask
endclass
