class slave_agent_config extends uvm_object;

        `uvm_object_utils(slave_agent_config)

virtual Axi3_if vif;

uvm_active_passive_enum is_active = UVM_ACTIVE;

extern function new(string name = "slave_agent_config");

endclass: slave_agent_config

function slave_agent_config:: new(string name = "slave_agent_config");
        super.new(name);
endfunction: new

