class master_seqs extends uvm_sequence #(Axi3_trans);

        `uvm_object_utils(master_seqs)

        Axi3_trans req;

        extern function new(string name = "master_seqs");
endclass

function master_seqs::new(string name = "master_seqs");
        super.new(name);
endfunction

class master_fixed_seqs extends master_seqs;

        `uvm_object_utils(master_fixed_seqs)

        extern function new(string name = "master_fixed_seqs");
        extern task body();
endclass

function master_fixed_seqs::new(string name = "master_fixed_seqs");
        super.new(name);
endfunction

task master_fixed_seqs::body();

        repeat(50) begin

                req = Axi3_trans::type_id::create("req");
                start_item(req);
                if(!req.randomize() with {AWBURST == 2'b00; ARBURST ==2'b00;})
                begin
                `uvm_error(get_type_name(),"Randomization failed in fixed seqs")
                end
                //`uvm_info(get_type_name(), $sformatf("seqs randomized %s",req.sprint()), UVM_LOW)
                finish_item(req);
        end

   #5000;

endtask

class master_incr_seqs extends master_seqs;

        `uvm_object_utils(master_incr_seqs)

        extern function new(string name = "master_incr_seqs");
        extern task body();
endclass

function master_incr_seqs::new(string name = "master_incr_seqs");
        super.new(name);
endfunction

task master_incr_seqs::body();

        repeat(50) begin

                req = Axi3_trans::type_id::create("req");
                start_item(req);
                if(!req.randomize() with {AWBURST == 2'b01; ARBURST ==2'b01;})
                begin
                `uvm_error(get_type_name(),"Randomization failed in incr seqs")
                end
                finish_item(req);
        end

   #5000;

endtask

class master_wrap_seqs extends master_seqs;

        `uvm_object_utils(master_wrap_seqs)

        extern function new(string name = "master_wrap_seqs");
        extern task body();
endclass

function master_wrap_seqs::new(string name = "master_wrap_seqs");
        super.new(name);
endfunction

task master_wrap_seqs::body();

        repeat(50) begin

                req = Axi3_trans::type_id::create("req");
                start_item(req);
                if(!req.randomize() with {AWBURST == 2'b10; ARBURST ==2'b10;})
                begin
                `uvm_error(get_type_name(),"Randomization failed in wrap seqs")
                end
                finish_item(req);
        end

   #5000;

endtask

class master_random_seqs extends master_seqs;

        `uvm_object_utils(master_random_seqs)

        extern function new(string name = "master_random_seqs");
        extern task body();
endclass

function master_random_seqs::new(string name = "master_random_seqs");
        super.new(name);
endfunction

task master_random_seqs::body();

        repeat(50) begin

                req = Axi3_trans::type_id::create("req");
                start_item(req);
                if(!req.randomize() )
                begin
                `uvm_error(get_type_name(),"Randomization failed in random seqs")
                end
                finish_item(req);
        end

   #5000;

endtask

class master_multiple_outstanding_seqs extends master_seqs;

        `uvm_object_utils(master_multiple_outstanding_seqs)

        extern function new(string name = "master_multiple_outstanding_seqs");
        extern task body();
endclass

function master_multiple_outstanding_seqs::new(string name = "master_multiple_outstanding_seqs");
        super.new(name);
endfunction

task master_multiple_outstanding_seqs::body();

        for(int i = 0; i < 50; i = i+1)  begin

                req = Axi3_trans::type_id::create("req");
                start_item(req);
                if(!req.randomize() with{

                AWBURST inside {2'b00, 2'b01, 2'b10};
                ARBURST inside {2'b00, 2'b01, 2'b10};

                AWLEN inside {[0:15]};
                ARLEN inside {[0:15]};

                AWSIZE inside {[0:2]};
                ARSIZE inside {[0:2]};

                        } )

                begin
                `uvm_error(get_type_name(),"Randomization failed in random seqs")
                end
                finish_item(req);
                `uvm_info("MULTI_OUT", $sformatf("Transaction %0d generated, AWID=%0d, \nARID=%0d", i, req.AWID, req.ARID),
                      UVM_MEDIUM)
        end

   #5000;

endtask

