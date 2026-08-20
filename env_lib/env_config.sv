class Axi3_env_config extends uvm_object;

        `uvm_object_utils(Axi3_env_config)

master_agent_config m_cfg[];
slave_agent_config s_cfg[];   //for reusability - if more masters and slaves are created

int no_of_master_agents;
int no_of_slave_agents;

bit has_scoreboard;
bit has_virtual_sequencer;

extern function new(string name = "Axi3_env_config");

endclass

function Axi3_env_config::new(string name = "Axi3_env_config");
        super.new(name);
endfunction: new
