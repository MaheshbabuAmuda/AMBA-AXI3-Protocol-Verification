class Axi3_test extends uvm_test;

        `uvm_component_utils(Axi3_test);

        Axi3_env envh;
        Axi3_env_config env_cfg;

        extern function new(string name = "Axi3_test", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function Axi3_test::new(string name = "Axi3_test", uvm_component parent);
        super.new(name, parent);
endfunction: new

function void Axi3_test::build_phase(uvm_phase phase);
        super.build_phase(phase);

        env_cfg = Axi3_env_config::type_id::create("env_cfg");

        env_cfg.no_of_master_agents = 1;
        env_cfg.no_of_slave_agents = 1;

        env_cfg.has_scoreboard = 1;
        env_cfg.has_virtual_sequencer = 1;

        env_cfg.m_cfg = new[env_cfg.no_of_master_agents];
        env_cfg.s_cfg = new[env_cfg.no_of_slave_agents];

  // Create Master Agent Configs
  foreach(env_cfg.m_cfg[i])
        begin
            env_cfg.m_cfg[i] = master_agent_config::type_id::create($sformatf("m_cfg[%0d]",i));

  // Get Master Virtual Interface
        if (!uvm_config_db#(virtual Axi3_if)::get(this,"", "vif", env_cfg.m_cfg[i].vif))
            `uvm_fatal("VIF_CONFIG","Cannot get vif from uvm_config_db. Have you set() it?")
        end
  // Create Slave Agent Configs
  foreach(env_cfg.s_cfg[i])
        begin
            env_cfg.s_cfg[i] = slave_agent_config::type_id::create($sformatf("s_cfg[%0d]",i));

        if (!uvm_config_db#(virtual Axi3_if)::get(this,"", "vif", env_cfg.s_cfg[i].vif))
            `uvm_fatal("VIF_CONFIG","Cannot get vif from uvm_config_db. Have you set() it?")
        end
  // Pass Environment Configuration
        uvm_config_db #(Axi3_env_config)::set(null,"*","Axi3_env_config", env_cfg);

  // Create Environment
        envh = Axi3_env::type_id::create("envh",this);

endfunction: build_phase

function void Axi3_test::end_of_elaboration_phase(uvm_phase phase);

  super.end_of_elaboration_phase(phase);
  
  // Print Topology
  uvm_top.print_topology();

endfunction: end_of_elaboration_phase

//Fixed sequence test
class fixed_seq_test extends Axi3_test;

    `uvm_component_utils(fixed_seq_test)

    fixed_vseq fixed_seq;

function new(string name = "fixed_seq_test", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        // Create virtual sequence
        fixed_seq = fixed_vseq::type_id::create("fixed_seq");
        // Start virtual sequence on virtual sequencer
        fixed_seq.start(envh.v_seqrh);
        phase.drop_objection(this);

endtask

endclass

//INCR sequence test
class incr_seq_test extends Axi3_test;

    `uvm_component_utils(incr_seq_test)

    incr_vseq incr_seq;

function new(string name = "incr_seq_test", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        incr_seq = incr_vseq::type_id::create("incr_seq");
        incr_seq.start(envh.v_seqrh);
        phase.drop_objection(this);

endtask

endclass

//WRAP sequence test
class wrap_seq_test extends Axi3_test;

    `uvm_component_utils(wrap_seq_test)

    wrap_vseq wrap_seq;

function new(string name = "wrap_seq_test", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
       super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        wrap_seq = wrap_vseq::type_id::create("wrap_seq");
        wrap_seq.start(envh.v_seqrh);
        phase.drop_objection(this);

endtask

endclass

//RANDOM sequence test
class random_seq_test extends Axi3_test;

    `uvm_component_utils(random_seq_test)

    random_vseq random_seq;

function new(string name = "random_seq_test", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        random_seq = random_vseq::type_id::create("random_seq");
        random_seq.start(envh.v_seqrh);
        phase.drop_objection(this);

endtask

endclass

//multiple_outstanding_test
class multiple_outs_test extends Axi3_test;

        `uvm_component_utils(multiple_outs_test)

        multiple_outstanding_vseq mult_seq;

function new(string name = "multiple_outs_test", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
        super.build_phase(phase);
endfunction

task run_phase(uvm_phase phase);

        phase.raise_objection(this);
        mult_seq = multiple_outstanding_vseq::type_id::create("mult_seq");
        mult_seq.start(envh.v_seqrh);
        phase.drop_objection(this);
endtask

endclass

