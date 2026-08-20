class slave_seqs extends uvm_sequence #(Axi3_transaction);

        `uvm_object_utils(slave_seqs)

        extern function new(string name = "slave_seqs");
endclass

function slave_seqs::new(string name = "slave_seqs");
        super.new(name);
endfunction: new
