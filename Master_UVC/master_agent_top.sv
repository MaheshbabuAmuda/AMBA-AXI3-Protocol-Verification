class master_agent_top extends uvm_env;

        `uvm_component_utils(master_agent_top)

        master_agent m_agnth[];
        Axi3_env_config env_cfg;

extern function new(string name = "master_agent_top", uvm_component parent);
extern function void build_phase(uvm_phase phase);

endclass


function master_agent_top::new(string name = "master_agent_top", uvm_component parent);
        super.new(name, parent);
endfunction

function void master_agent_top::build_phase(uvm_phase phase);
        super.build_phase(phase);

         // Get environment configuration
    if (!uvm_config_db#(Axi3_env_config)::get(this, "", "Axi3_env_config", env_cfg))
        `uvm_fatal(get_type_name(),"Failed to get Axi3_env_config from config_db")


          // Allocate the dynamic array
          m_agnth = new[env_cfg.no_of_master];

        foreach(m_agnth[i]) begin
        m_agnth[i] = master_agent::type_id::create($sformatf("m_agnth[%0d]",i), this);
        end
endfunction
