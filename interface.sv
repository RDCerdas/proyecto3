// Interfaz original
interface fifo_if #(parameter width =16) (
  input clk
);
  logic rst;
  logic pndng;
  logic full;
  logic push;
  logic pop;
  logic [width-1:0] dato_in; 
  logic [width-1:0] dato_out;

  endinterface
