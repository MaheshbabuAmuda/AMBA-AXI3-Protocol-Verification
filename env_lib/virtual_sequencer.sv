class Axi3_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

        `uvm_component_utils(Axi3_virtual_sequencer)

        //actual sequencers:
        master_sequencer m_seqrh[];
        slave_sequencer s_seqrh[];

        Axi3_env_config env_cfg;

        extern function new(string name = "Axi3_virtual_sequencer", uvm_component parent);
        extern function void build_phase(uvm_phase phase);

endclass


function Axi3_virtual_sequencer::new(string name = "Axi3_virtual_sequencer", uvm_component parent);
        super.new(name, parent);
endfunction: new

function void Axi3_virtual_sequencer::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(Axi3_env_config)::get(this,"","Axi3_env_config", env_cfg))
         begin
          `uvm_fatal("VIRTUAL_SEQUENCE","Error while getting Axi3_env_config")
         end

        // Allocate size to local sequencer arrays
         m_seqrh = new[env_cfg.no_of_master_agents];
         s_seqrh = new[env_cfg.no_of_slave_agents];

endfunction: build_phase
