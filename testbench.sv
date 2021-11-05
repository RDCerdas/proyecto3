import uvm_pkg::*;


  parameter width = 16;
  parameter depth = 8;


`include "fifo.sv"
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
  fifo_if  #(.width(width)) _if(.clk(clk));
  initial begin
    clk = 0;
    forever #5 clk = ~ clk;
  end

  fifo_flops #(.depth(depth),.bits(width)) uut(
    .Din(_if.dato_in),
    .Dout(_if.dato_out),
    .push(_if.push),
    .pop(_if.pop),
    .clk(_if.clk),
    .full(_if.full),
    .pndng(_if.pndng),
    .rst(_if.rst)
  );


  initial begin
    uvm_top.enable_print_topology = 1;

    uvm_top.set_report_verbosity_level(UVM_LOW);

    uvm_config_db #(virtual fifo_if)::set(null, "uvm_test_top", "_if", _if);

    run_test();
  end
 
endmodule
