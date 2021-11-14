
import uvm_pkg::*;

// Package to store al current variables for report
class report_package extends uvm_object;
  `uvm_object_utils_begin(report_package)
  `uvm_field_int(m_time, UVM_DEFAULT|UVM_DEC)
  `uvm_field_int(m_r_mode, UVM_DEFAULT)
  `uvm_field_int(m_fp_X, UVM_DEFAULT)
  `uvm_field_int(m_fp_Y, UVM_DEFAULT)
  `uvm_field_int(m_fp_Z,UVM_DEFAULT)
  `uvm_field_int(m_fp_Z_expected, UVM_DEFAULT)
  `uvm_field_int(m_fp_Z_long, UVM_DEFAULT)
  `uvm_object_utils_end

  // Variables to save from each package
  int m_time;
  bit [2:0] m_r_mode;
  bit [31:0] m_fp_X;
  bit [31:0] m_fp_Y;
  bit [31:0] m_fp_Z;
  bit [31:0] m_fp_Z_expected;
  bit [63:0] m_fp_Z_long;

  function new(string name = "report_package");
    super.new(name);
  endfunction

  //Function to write to file in csv format
  function void fwrite(int file);
    $fwrite(file, "%0d, %0h, %0h, %0h, %0h, %0h, %0h\n", this.m_time, this.m_r_mode, this.m_fp_X, this.m_fp_Y, this.m_fp_Z, this.m_fp_Z_expected, this.m_fp_Z_long);
  endfunction
endclass

// Union de checker scoreboard, se le añaden colas del scoreboard
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils_begin(scoreboard)
  	`uvm_field_int(trans_fp_Y, UVM_DEFAULT)
  	`uvm_field_int(trans_fp_X, UVM_DEFAULT)
  	`uvm_field_int(trans_fp_Z, UVM_DEFAULT)
  	`uvm_field_int(trans_r_mode, UVM_DEFAULT)
    `uvm_field_int(m_fp_Z_bits, UVM_DEFAULT)
  	`uvm_field_int(m_fp_Z_32_mult, UVM_DEFAULT)
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
  
  // Variables for printing package variables
  bit [31:0] trans_fp_Y;
  bit [31:0] trans_fp_X;
  bit [31:0] trans_fp_Z;
  bit [2:0] trans_r_mode;

  // Variables to store multiplication data
  shortreal m_fp_Y;
  shortreal m_fp_X;
  real m_fp_Y_real;
  real m_fp_X_real;
  real m_fp_Z;
  bit [31:0] m_fp_Z_32_mult;
  bit [63:0] m_fp_Z_bits;

  // Expected and rounding vairables
  bit [31:0] m_fp_Z_expected;
  bit m_ovrf_expected;
  bit m_udrf_expected;
  bit m_round_bit;
  bit m_guard_bit;
  bit m_sticky_bit;
  bit m_sign_bit;

  // Variables to round up
  bit [7:0] z_plus_exp;
  bit [23:0] z_plus_mant;

  // Queue to store data until report phase
  report_package report_queue[$];

  // csv file to store report
  int file_csv;

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction 

  virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	m_analysis_imp = new("m_analysis_imp", this);
  endfunction

  // Function to save transaction in queue
  function void save_transaction(trans_mul t);
    report_package pkg = report_package::type_id::create("pkg");

    // Give each value to each packet
    pkg.m_time = t.m_time;
    pkg.m_r_mode = t.r_mode;
    pkg.m_fp_X = t.fp_X;
    pkg.m_fp_Y = t.fp_Y;
    pkg.m_fp_Z = t.fp_Z;
    pkg.m_fp_Z_expected = this.m_fp_Z_expected;
    pkg.m_fp_Z_long = this.m_fp_Z_bits;

    // Saves it on queue
    this.report_queue.push_back(pkg);
  endfunction

  virtual function void write(trans_mul t);
    // Transfer transaction data to local variables for printing
    trans_fp_Y = t.fp_Y;
    trans_fp_X = t.fp_X;
    trans_fp_Z = t.fp_Z;
    trans_r_mode = t.r_mode;
    
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
      // If it is 0 sign bit doesn't matter
      m_fp_Z_expected[31] = t.fp_Z[31];
      m_fp_Z_expected[30:23] = '0;
      m_fp_Z_expected[22:0] = '0;
      m_ovrf_expected = 0;
      m_udrf_expected = 1;

    // If inf or Nan
    end else if ((m_fp_Z_32_mult[30:23] == 8'hFF)) begin
      // Inf or Nan
      // Sign bit doesn't matter
      m_fp_Z_expected[31] = t.fp_Z[31];
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
      `uvm_error("SCOREBOARD", $sformatf("Invalid result\nExpected = %h, receive = %h \novrf_expected = %h, receive = %h \nundrflw_expected = %h, receive = %h \n\n %s", 
       m_fp_Z_expected, t.fp_Z, m_ovrf_expected, t.ovrf, m_udrf_expected, t.udrf, this.sprint()));
    end

    // Saves transaction for queue for later report
    this.save_transaction(t);

  endfunction

    virtual function void report_phase(uvm_phase phase);
		// Report of every package
    	super.report_phase(phase);
      `uvm_info("SCOREBOARD REPORT", $sformatf(" Generating report"), UVM_LOW);

      // Open file for writting 
      file_csv = $fopen("report.csv", "w");
      // Write csv header
      $fwrite(file_csv, "Time,Rounding Mode,fp_X,fp_Y,fp_Z,fp_Z Expected,fp_Z 64 bits\n");

      // Until no transactions left
      while (this.report_queue.size() > 0) begin
        report_package transaction;
        transaction = this.report_queue.pop_front();
        `uvm_info("SCOREBOARD REPORT", $sformatf("Transaction \n%s", transaction.sprint()), UVM_MEDIUM);
        transaction.fwrite(file_csv);
      end
      $fclose(file_csv);
    endfunction
endclass 


