class slave_agent_top extends uvm_env;

        `uvm_component_utils(slave_agent_top)

        slave_agent s_agnth;

        Axi3_env_config env_cfg;

extern function new(string name = "slave_agent_top" , uvm_component parent);
extern function void build_phase(uvm_phase phase);

endclass

function slave_agent_top::new(string name = "slave_agent_top" , uvm_component parent);
        super.new(name, parent);
endfunction: new

function void slave_agent_top::build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get environment configuration
    if (!uvm_config_db#(Axi3_env_config)::get(this, "", "Axi3_env_config", env_cfg))
        `uvm_fatal(get_type_name(),"Failed to get Axi3_env_config from config_db")

        s_agnth = slave_agent::type_id::create("s_agnth", this);

endfunction: build_phase
