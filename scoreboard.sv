
import uvm_pkg::*;

// Union de checker scoreboard, se le añaden colas del scoreboard
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils_begin(scoreboard)
    `uvm_field_real(m_fp_Y, UVM_DEFAULT)
    `uvm_field_real(m_fp_X, UVM_DEFAULT)
    `uvm_field_real(m_fp_Z_bits, UVM_DEFAULT) 
    `uvm_field_int(m_sign_bit, UVM_DEFAULT)
    `uvm_field_int(m_round_bit, UVM_DEFAULT)
    `uvm_field_int(m_guard_bit, UVM_DEFAULT)
    `uvm_field_int(m_sticky_bit, UVM_DEFAULT)
    `uvm_field_int(m_fp_Z_expected, UVM_DEFAULT)
    `uvm_field_int(m_ovrf_expected, UVM_DEFAULT)
    `uvm_field_int(m_udrf_expected, UVM_DEFAULT)
  `uvm_component_utils_end
  // Puerto de transacciones del driver
  uvm_analysis_imp #(trans_mul, scoreboard) m_analysis_imp;

  shortreal m_fp_Y;
  shortreal m_fp_X;
  real m_fp_Y_real;
  real m_fp_X_real;
  real m_fp_Z;
  bit [31:0] m_fp_Z_32_mult;
  bit [63:0] m_fp_Z_bits;

  bit [31:0] m_fp_Z_expected;
  bit m_ovrf_expected;
  bit m_udrf_expected;
  bit m_round_bit;
  bit m_guard_bit;
  bit m_sticky_bit;
  bit m_sign_bit;

  bit [7:0] z_plus_exp;
  bit [23:0] z_plus_mant;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  virtual function void write(trans_mul t);
    `uvm_info("SCOREBOARD", $sformatf("\nTransaction received\n%s\n", t.sprint()), UVM_DEBUG)
    // Conversion de shortreal type
    m_fp_Y = $bitstoshortreal(t.fp_Y);
    m_fp_X = $bitstoshortreal(t.fp_X);

    m_fp_Y_real = m_fp_Y;
    m_fp_X_real = m_fp_X;

    // 64 bits operation
    m_fp_Z = m_fp_Y_real*m_fp_X_real;



    // Convert to 32 bit representation
    m_fp_Z_32_mult = $shortrealtobits(m_fp_Z);

    // If underflow
    if (m_fp_Z_32_mult[30:23] == 0) begin
      // Expected Exp = 0 y Fracc = 0
      m_fp_Z_expected[31] = m_fp_Z_32_mult[31];
      m_fp_Z_expected[30:23] = '0;
      m_fp_Z_expected[22:0] = '0;
      m_ovrf_expected = 0;
      m_udrf_expected = 1;

    // If inf or Nan
    end else if ((m_fp_Z_32_mult[30:23] == 8'hFF)) begin
      // Inf or Nan
      m_fp_Z_expected[31] = m_fp_Z_32_mult[31];
      m_fp_Z_expected[22:0] = m_fp_Z_32_mult[22:0];
      m_fp_Z_expected[30:23] = 8'hFF;
      m_ovrf_expected = (m_fp_Z_expected[22])? 0 : 1;
      m_udrf_expected = 0;

    // If not a special case
    end else begin
      // Converts to 64 binary representation to use the extra bits
      m_fp_Z_bits = $realtobits(m_fp_Z);

      // Not ovr or udrf expected
      m_ovrf_expected = 0;
      m_udrf_expected = 0;

      // Same sign bit
      m_fp_Z_expected[31] = m_fp_Z_bits[63];

      // Conversion from 64 bit exponent to 32
      m_fp_Z_expected[30:23] = m_fp_Z_bits[62:52]-896;

      // Extracts round, guard and sticky from double
      m_round_bit = m_fp_Z_bits[28];
      m_guard_bit = m_fp_Z_bits[27];
      m_sticky_bit = m_fp_Z_bits[26];
      m_sign_bit = m_fp_Z_expected[31];

      z_plus_mant = m_fp_Z_bits[51:29] + 1;
      z_plus_exp = m_fp_Z_expected[30:23];

      // If carry out occurs shift right and subtract 1 from exp
      if(z_plus_mant[23] == 1) begin
        z_plus_mant = z_plus_mant >> 1;
      	z_plus_exp = z_plus_exp - 1;
      end

      // For each rounding mode
      case (t.r_mode)
        // Round to nearest ties to even
        3'b000: begin
          // If round bit is 0 truncate
          if (m_round_bit == 0) begin
             m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
          // If round 1 and sticky or guard 1 sum 1
          end else if (m_round_bit && (m_guard_bit || m_sticky_bit)) begin
             m_fp_Z_expected[30:23]  = z_plus_exp;
             m_fp_Z_expected[22:0] = z_plus_mant[22:0];
          end else begin
            // Choose even
            if(m_fp_Z_bits[29]==0) begin
              m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
            end else begin
              m_fp_Z_expected[30:23]  = z_plus_exp;
              m_fp_Z_expected[22:0] = z_plus_mant[22:0];
            end
          end

        end

        // Round to zero
        3'b001: begin
          m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
        end

        // Round toward -inf
        3'b010: begin
          // If positive
          if(m_sign_bit == 0) begin
            m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];

          // If negative
          end else begin
            m_fp_Z_expected[30:23]  = z_plus_exp;
            m_fp_Z_expected[22:0] = z_plus_mant[22:0];
          end
        end

        // Round toward +inf
        3'b011: begin
          // If positive
          if(m_sign_bit == 0) begin
            m_fp_Z_expected[30:23]  = z_plus_exp;
            m_fp_Z_expected[22:0] = z_plus_mant[22:0];
          
          // If negative
          end else begin
            m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
          end
        end

        // Round to nearest, ties away from zero
        3'b100: begin
          // If round 0
          if(m_round_bit == 0) begin
            m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
          // Else
          end else begin
            m_fp_Z_expected[30:23]  = z_plus_exp;
            m_fp_Z_expected[22:0] = z_plus_mant[22:0];
          end
        end

        // Default case
        default: begin
          m_fp_Z_expected[22:0] = m_fp_Z_bits[51:29];
        end
      endcase
    end

    //$display("64 bit float = %h  round method = %h", m_fp_Z_bits, t.r_mode);

    // Compares the result from the DUT from the expected
    if (m_fp_Z_expected != t.fp_Z || t.ovrf != m_ovrf_expected || t.udrf != m_udrf_expected) begin
      `uvm_error("SCOREBOARD", $sformatf("Invalid result\nRounding mode = %b, \nExpected = %h, receive = %h \novrf_expected = %h, receive = %h \nundrflw_expected = %h, receive = %h \n\n %s", t.r_mode, 
       m_fp_Z_expected, t.fp_Z, m_ovrf_expected, t.ovrf, m_udrf_expected, t.udrf, this.sprint()));
    end

  endfunction

    virtual function void report_phase(uvm_phase phase);
		// Reporte de misses y matches al final de la corrida
    // Se realiza el reporte al igual que con el scoreboard original
    	super.report_phase(phase);
        `uvm_info("SCOREBOARD REPORT", $sformatf("\nScore board: el retardo promedio"), UVM_LOW);
    endfunction
endclass 


