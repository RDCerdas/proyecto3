// Interfaz original
interface mult_if(
  input clk
);
  logic [2:0] r_mode;
  logic [31:0] fp_X;
  logic [31:0] fp_Y;
  logic [31:0] fp_Z;
  logic ovrf;
  logic udrf;

  endinterface
