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
  int zero;
  int infinite;
  always @ * begin
    if (t.fp_Z[30:0] == 0) begin
      zero=1;
      _assert_zero:assert property ( zero |->  t.udrf)
      else `uvm_error("Test","Error underflow flag")
      zero=0;
    end else if ((t.fp_Z[22:0] == 0) && (t.fp_Z[30:23] == 8'hFF) ) begin
      infinite = 1;
      _assert_inf:assert property ( infinite |->  t.ovrf)
      else `uvm_error("Test","Error overflow flag")
      infinite = 0; 
  end
end


 
endmodule
