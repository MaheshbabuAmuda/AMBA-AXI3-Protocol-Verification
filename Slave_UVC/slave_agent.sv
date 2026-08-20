class slave_agent extends uvm_agent;

        `uvm_component_utils(slave_agent)

        slave_agent_config s_cfg;

        slave_driver drvh;
        slave_monitor monh;
        slave_sequencer seqrh;

extern function new(string name = "slave_agent", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass

function slave_agent::new(string name = "slave_agent", uvm_component parent);
        super.new(name, parent);
endfunction: new

function void slave_agent::build_phase(uvm_phase phase);
        super.build_phase(phase);


        if(!uvm_config_db #(slave_agent_config)::get(this,"","slave_agent_config", s_cfg))
        `uvm_fatal("SLAVE_CONFIG", "cannot get(), have u set() slave_agent_config")

        monh = slave_monitor::type_id::create("monh", this);

        if(s_cfg.is_active == UVM_ACTIVE)
        begin
        drvh = slave_driver::type_id::create("drvh", this);
        seqrh = slave_sequencer::type_id::create("seqrh", this);
        end

endfunction: build_phase

function void slave_agent::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if(s_cfg.is_active == UVM_ACTIVE)
        begin
                drvh.seq_item_port.connect(seqrh.seq_item_export);
        end
endfunction: connect_phase
