
import uvm_pkg::*;

// Union de checker scoreboard, se le añaden colas del scoreboard
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  // Puerto de transacciones del driver
  uvm_analysis_imp #(trans_mul, scoreboard) m_analysis_imp;

  shortreal m_fp_Y;
  shortreal m_fp_X;
  real m_fp_Z;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function void write(trans_mul t);
    `uvm_info("SCOREBOARD", $sformatf("\nTransaction received\n%s\n", t.sprint()), UVM_DEBUG)
    m_fp_Y = $bitstoshortreal(t.fp_Y);
    m_fp_X = $bitstoshortreal(t.fp_X);
    m_fp_Z = m_fp_Y*m_fp_X;
    m_fp_Z = $realtobits(m_fp_Z);
    $display("fp_Y = %h, fp_X = %h, m_fp_Y = %h, m_fp_X = %h", t.fp_Y, t.fp_X, m_fp_Y, m_fp_X);    
    $display("fp_Z = %h, m_fp_Z = %h", t.fp_Z, m_fp_Z); 
  endfunction

    virtual function void report_phase(uvm_phase phase);
		// Reporte de misses y matches al final de la corrida
    // Se realiza el reporte al igual que con el scoreboard original
    	super.report_phase(phase);
        `uvm_info("SCOREBOARD REPORT", $sformatf("\nScore board: el retardo promedio"), UVM_LOW);
    endfunction
endclass 


