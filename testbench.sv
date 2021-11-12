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
 
endmodule
