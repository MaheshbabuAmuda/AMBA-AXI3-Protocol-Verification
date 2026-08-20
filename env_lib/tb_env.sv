class Axi3_env extends uvm_env;

        `uvm_component_utils(Axi3_env)

        Axi3_env_config env_cfg;

        master_agent_top m_top[];
        slave_agent_top s_top[];

        Axi3_scoreboard sb_h;
        Axi3_virtual_sequencer v_seqrh;

extern function new(string name = "Axi3_env", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);

endclass

function Axi3_env::new(string name = "Axi3_env", uvm_component parent);
        super.new(name, parent);
endfunction: new

function void Axi3_env::build_phase(uvm_phase phase);
        super.build_phase(phase);

        //1.get env_config:
        if(!uvm_config_db #(Axi3_env_config)::get(this,"","Axi3_env_config",env_cfg))
        `uvm_fatal("ENV_CONFIG", "cannot get() env_config_obj")


        if(env_cfg.no_of_master_agents) begin

                m_top = new[env_cfg.no_of_master_agents];

                foreach(m_top[i]) begin

                uvm_config_db #(master_agent_config)::set(this,$sformatf("m_top[%0d]*",i),  "master_agent_config", env_cfg.m_cfg[i]);

                m_top[i] = master_agent_top::type_id::create($sformatf("m_top[%0d]",i), this);

                end

        end

        if(env_cfg.no_of_slave_agents) begin

                s_top = new[env_cfg.no_of_slave_agents];

                foreach(s_top[i]) begin

                uvm_config_db #(slave_agent_config)::set(this,$sformatf("s_top[%0d]*", i), "slave_agent_config", env_cfg.s_cfg[i]);

                s_top[i] = slave_agent_top::type_id::create($sformatf("s_top[%0d]", i), this);

                end

        end

        if(env_cfg.has_virtual_sequencer) begin
                v_seqrh =Axi3_virtual_sequencer::type_id::create("v_seqrh", this);
        end

        if(env_cfg.has_scoreboard) begin
                sb_h = Axi3_scoreboard::type_id::create("sb_h", this);
        end

endfunction: build_phase

function void Axi3_env::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

         if(env_cfg.has_virtual_sequencer)
           begin
                 foreach(m_top[i]) begin
                         v_seqrh.m_seqrh[i] = m_top[i].m_agnth.seqrh;
                  end

                 foreach(s_top[i]) begin
                         v_seqrh.s_seqrh[i] = s_top[i].s_agnth.seqrh;
                 end
          end

         if(env_cfg.has_scoreboard)
           begin
                 foreach(m_top[i]) begin
                         m_top[i].m_agnth.monh.monitor_port.connect(sb_h.mstr_fifo_h[i].analysis_export);
                  end

                foreach(s_top[i]) begin
                         s_top[i].s_agnth.monh.monitor_port.connect(sb_h.slv_fifo_h[i].analysis_export);
                 end
           end

endfunction: connect_phase

