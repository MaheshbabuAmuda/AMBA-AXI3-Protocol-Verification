package Axi3_pkg;

  import uvm_pkg::*;
  
    `include "uvm_macros.svh"
  
    `include "Axi3_trans.sv"
  
    `include "master_config.sv"
    `include "slave_config.sv"
    `include "env_config.sv"
  
    `include "master_seqs.sv"
    // Master UVC
    `include "master_sequencer.sv"
    `include "master_driver.sv"
    `include "master_monitor.sv"
    `include "master_agent.sv"
    `include "master_agent_top.sv"
  
    // Slave UVC
    `include "slave_sequencer.sv"
    `include "slave_driver.sv"
    `include "slave_monitor.sv"
    `include "slave_agent.sv"
    `include "slave_agent_top.sv"
  
    // Environment Components
    `include "Axi3_virtual_sequencer.sv"
    `include "Axi3_virtual_seq.sv"
    `include "Axi3_scoreboard.sv"
    `include "tb_env.sv"
  
    // Test
    `include "test.sv"

endpackage
