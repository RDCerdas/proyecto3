
import uvm_pkg::*;

// Union de checker scoreboard, se le añaden colas del scoreboard
class scoreboard #(parameter width =16, parameter depth = 8) extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  // Puerto de transacciones del driver
  uvm_analysis_imp #(trans_fifo, scoreboard) m_analysis_imp;

  // Report variables
  trans_sb auxiliar_trans;
  int tamano_sb = 0;
  trans_sb score_board[$]; // esta es la estructura dinámica que maneja el scoreboard  
  int transacciones_completadas = 0;
  int retardo_total = 0;
  int retardo_promedio = 0;

  trans_fifo #(.width(width)) transaccion; //transacción recibida en el mailbox 
  trans_fifo #(.width(width)) auxiliar; //transacción usada como auxiliar para leer el fifo emulado 
  trans_sb   #(.width(width)) to_sb; // transacción usada para comunicarse con el scoreboard
  trans_fifo  emul_fifo[$]; //this queue is going to be used as golden reference for the fifo
  int contador_auxiliar; 



  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
    this.emul_fifo = {};
    this.contador_auxiliar = 0;
  endfunction 

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function void write(trans_fifo transaccion);
    `uvm_info("SCOREBOARD", $sformatf("\nTransaction received\n%s\n", transaccion.sprint()), UVM_DEBUG)
     to_sb = trans_sb::type_id::create("trans_sb");
     case(transaccion.tipo)
       lectura: begin
         if(0 !== emul_fifo.size()) begin //Revisa si el Fifo no está vacía
           auxiliar = emul_fifo.pop_front();
           if(transaccion.dato == auxiliar.dato) begin
             to_sb.dato_enviado = auxiliar.dato;
             to_sb.tiempo_push = auxiliar.tiempo;
             to_sb.tiempo_pop = transaccion.dato;
             to_sb.completado = 1;
             to_sb.calc_latencia();
            if(to_sb.completado) begin
             retardo_total = retardo_total + to_sb.latencia;
             transacciones_completadas++;
            end
             score_board.push_back(to_sb);
           end else begin
              `uvm_error("SCOREBOARD", $sformatf("Dato_leido= %h, Dato_Esperado = %h",transaccion.dato,auxiliar.dato));
              //$finish; 
           end
         end else begin // si está vacía genera un underflow 
             to_sb.tiempo_pop = transaccion.tiempo;
             to_sb.underflow = 1;
             if(to_sb.completado) begin
              retardo_total = retardo_total + to_sb.latencia;
              transacciones_completadas++;
             end
             score_board.push_back(to_sb);
         end
       end
       escritura: begin
         if(emul_fifo.size() == depth)begin // Revisa si la Fifo está llena para generar un overflow
           auxiliar = emul_fifo.pop_front();
           to_sb.dato_enviado = auxiliar.dato;
           to_sb.tiempo_push = auxiliar.tiempo;
           to_sb.overflow = 1;
           if(to_sb.completado) begin
            retardo_total = retardo_total + to_sb.latencia;
            transacciones_completadas++;
           end
           score_board.push_back(to_sb);
           emul_fifo.push_back(transaccion);
         end else begin  // En caso de no estar llena simplemente guarda el dato en la fifo simulada
           emul_fifo.push_back(transaccion);
         end
       end
       reset: begin // en caso de reset vacía la fifo simulada y envía todos los datos perdidos al SB
         contador_auxiliar = emul_fifo.size();
         for(int i =0; i<contador_auxiliar; i++)begin
           auxiliar = emul_fifo.pop_front();
           to_sb.clean();
           to_sb.dato_enviado = auxiliar.dato;
           to_sb.tiempo_push = auxiliar.tiempo;
           to_sb.reset = 1;
           if(to_sb.completado) begin
            retardo_total = retardo_total + to_sb.latencia;
            transacciones_completadas++;
           end
           score_board.push_back(to_sb);
         end
       end
       default: begin
         `uvm_error("SCOREBOARD", $sformatf("La transacción recibida no tiene tipo valido",$time));
         $finish;
       end
     endcase    
  endfunction

    virtual function void report_phase(uvm_phase phase);
		// Reporte de misses y matches al final de la corrida
    // Se realiza el reporte al igual que con el scoreboard original
    	super.report_phase(phase);
        tamano_sb = this.score_board.size();
            for(int i=0;i<tamano_sb;i++) begin
                auxiliar_trans = score_board.pop_front;
                `uvm_info("SCOREBOARD REPORT", $sformatf("\n%s", auxiliar_trans.sprint()), UVM_LOW)
        end
        retardo_promedio = retardo_total/transacciones_completadas;
        `uvm_info("SCOREBOARD REPORT", $sformatf("\n[%g] Score board: el retardo promedio es: %0.3f", $time, retardo_promedio), UVM_LOW);
    endfunction
endclass 


