class Axi3_base_vseq extends uvm_sequence #(uvm_sequence_item);

        `uvm_object_utils(Axi3_base_vseq)

        master_sequencer m_seqrh[];
        slave_sequencer s_seqrh[];
        Axi3_virtual_sequencer v_seqrh;

        master_fixed_seqs fixed_seqs;
        master_incr_seqs incr_seqs;
        master_wrap_seqs wrap_seqs;
        master_random_seqs ran_seqs;
        master_multiple_outstanding_seqs mul_seqs;

        Axi3_env_config env_cfg;

        extern function new(string name = "Axi3_base_vseq");
        extern task body();

endclass


function Axi3_base_vseq::new(string name = "Axi3_base_vseq");
        super.new(name);
endfunction: new

task Axi3_base_vseq::body();

 if(!uvm_config_db #(Axi3_env_config)::get(null,"","Axi3_env_config", env_cfg))
    begin
        `uvm_fatal("VIRTUAL_SEQUENCE","Error while getting Axi3_env_config")
    end

        // Allocate size to local sequencer arrays
         m_seqrh = new[env_cfg.no_of_master_agents];
         s_seqrh = new[env_cfg.no_of_slave_agents];

         assert($cast(v_seqrh, m_sequencer)) else begin

        `uvm_fatal("VSEQ_CAST", "m_sequencer is not Axi3_virtual_sequencer")

         end

         // Connect master sequencer handles

        foreach(m_seqrh[i])
         begin

             m_seqrh[i] = v_seqrh.m_seqrh[i];

         end

    // Connect slave sequencer handles

        foreach(s_seqrh[i])
         begin

            s_seqrh[i] = v_seqrh.s_seqrh[i];

         end

endtask: body

//Fixed virtual sequence

class fixed_vseq extends Axi3_base_vseq;

    `uvm_object_utils(fixed_vseq)

    function new(string name = "fixed_vseq");
        super.new(name);
    endfunction

    task body();

        super.body();

            fixed_seqs = master_fixed_seqs::type_id::create("fixed_seqs");

        foreach(m_seqrh[i])
        begin

            fixed_seqs.start(m_seqrh[i]);

        end

    endtask

endclass

//INCR virtual sequence

class incr_vseq extends Axi3_base_vseq;

    `uvm_object_utils(incr_vseq)

    function new(string name = "incr_vseq");
        super.new(name);
    endfunction

    task body();

        super.body();

        incr_seqs =
            master_incr_seqs::type_id::create("incr_seqs");

        foreach(m_seqrh[i])
        begin

            incr_seqs.start(m_seqrh[i]);

        end

    endtask

endclass

//WRAP virtual sequence

class wrap_vseq extends Axi3_base_vseq;

    `uvm_object_utils(wrap_vseq)

    function new(string name = "wrap_vseq");
        super.new(name);
    endfunction

    task body();

        super.body();

        wrap_seqs =
            master_wrap_seqs::type_id::create("wrap_seqs");

        foreach(m_seqrh[i])
        begin

            wrap_seqs.start(m_seqrh[i]);

        end

    endtask

endclass

//RANDOM virtual sequence

class random_vseq extends Axi3_base_vseq;

    `uvm_object_utils(random_vseq)

    function new(string name = "random_vseq");
        super.new(name);
    endfunction

    task body();

        super.body();

        ran_seqs =
            master_random_seqs::type_id::create("ran_seqs");

        foreach(m_seqrh[i])
        begin

            ran_seqs.start(m_seqrh[i]);

        end

    endtask

endclass
          
//Multiple Outstanding virtual sequence

class multiple_outstanding_vseq extends Axi3_base_vseq;

    `uvm_object_utils(multiple_outstanding_vseq)

    function new(string name = "multiple_outstanding_vseq");
        super.new(name);
    endfunction

    task body();

        super.body();

        mul_seqs =
            master_multiple_outstanding_seqs::type_id::create("mul_seqs");

        foreach(m_seqrh[i])
        begin

            mul_seqs.start(m_seqrh[i]);

        end

    endtask

endclass

