module top;

  import uvm_pkg::*;
  import Axi3_pkg::*;
  `include "uvm_macros.svh"

// Clock Generation
  bit ACLK;
  always #5 ACLK = ~ACLK;

  // Interface Instance
  Axi3_if vif(ACLK);

  initial begin     // Set Virtual Interface
            uvm_config_db #(virtual Axi3_if)::set(null,"*","vif", vif);

    // Start UVM Test
            run_test( );
    end

endmodule
