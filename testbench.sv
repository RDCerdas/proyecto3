import uvm_pkg::*;


`include "multiplicador_32_bits_FP_IEEE.sv"
`include "interface.sv"
`include "seq_item.sv"
`include "sequence.sv"
`include "driver.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "env.sv"
`include "test.sv"

///////////////////////////////////
// Módulo para correr la prueba  //
///////////////////////////////////
module test_bench; 

  reg clk;

  mult_if _if(.clk(clk));

  initial begin
    clk = 0;
    forever #5 clk = ~ clk;
  end

  top DUT(.r_mode(_if.r_mode),
          .fp_X(_if.fp_X),
          .fp_Y(_if.fp_Y),
	  .clk(_if.clk),
          
          .fp_Z(_if.fp_Z),
          .ovrf(_if.ovrf),
          .udrf(_if.udrf));

  initial begin
    uvm_top.enable_print_topology = 1;

    uvm_top.set_report_verbosity_level(UVM_LOW);

    uvm_config_db #(virtual mult_if)::set(null, "uvm_test_top", "_if", _if);

    run_test();
  end

  // Aserciones
  // Se verifica que si fp_Z es infinito se levante la señál de overflow
  assert property (@(_if.fp_Z) _if.fp_Z[22:0] == 0 && _if.fp_Z[30:23] == 8'hFF |->  _if.ovrf)
      else `uvm_error("Test",$sformatf("Error overflow flag  overflow= %b", _if.ovrf ));
  // Se verifica que si fp_Z es cero se levante la bandera de underflow
  assert property (@(_if.fp_Z) _if.fp_Z[30:0] == 0 |->  _if.udrf)
      else `uvm_error("Test", $sformatf("Error underflow flag  underflow= %b", _if.udrf ));

 
endmodule
