class slave_driver extends uvm_driver#(Axi3_trans);

        `uvm_component_utils(slave_driver)

        virtual Axi3_if.SDRV vif;

        slave_agent_config s_cfg;

        Axi3_trans xtn_wr, xtn_rd;
        Axi3_trans q1[$], q2[$], q3[$];

        semaphore sem_Wac = new(1); //write addr channel
        semaphore sem_Wdc = new(1); //write data channel
        semaphore sem_Wrc = new(1); //write resp channel
        semaphore sem_Wddc = new(); //write data dependency channel
        semaphore sem_Wrdc = new(); //write resp dependency channel

        semaphore sem_Rac = new(1); //read addr channel
        semaphore sem_Rdc = new(1); //read data channel
        semaphore sem_Rddc = new(); //read data dependency channel


        extern function new(string name = "slave_driver", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

        extern task drive();

        extern task drive_awaddr(Axi3_trans xtn_wr);    //write_address recieves from master
        extern task drive_wdata(Axi3_trans xtn_wr);     //write_data recieves from master
        extern task drive_bresp(Axi3_trans xtn_wr);     //slve send response - okay

        extern task drive_raddr(Axi3_trans xtn_rd);
        extern task drive_rdata(Axi3_trans xtn_rd);
endclass

function slave_driver::new(string name = "slave_driver", uvm_component parent);
        super.new(name,parent);
endfunction: new

function void slave_driver::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(slave_agent_config)::get(this, "" , "slave_agent_config" , s_cfg ))
        `uvm_fatal("SLAVE_CONFIG", "cannot get(), HAve u set () slave_agent_config ?")
endfunction: build_phase

function void slave_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vif = s_cfg.vif;

endfunction: connect_phase

task slave_driver::run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
                drive();
        end
endtask: run_phase

task slave_driver::drive();
        xtn_wr = Axi3_trans::type_id::create("xtn_wr");
        xtn_rd = Axi3_trans::type_id::create("xtn_rd");
        fork
                begin
                        sem_Wac.get(1);
                        drive_awaddr(xtn_wr);
                        sem_Wac.put(1);
                        sem_Wddc.put(1);
                end

                begin
                        sem_Wdc.get(1);
                        sem_Wddc.get(1);
                        drive_wdata(q1.pop_front());
                        sem_Wdc.put(1);
                        sem_Wrdc.put(1);
                end

                begin
                        sem_Wrc.get(1);
                        sem_Wrdc.get(1);
                        drive_bresp(q2.pop_front());
                        sem_Wrc.put(1);
                end

                begin
                        sem_Rac.get(1);
                        drive_raddr(xtn_rd);
                        sem_Rac.put(1);
                        sem_Rddc.put(1);
                end

                begin
                        sem_Rddc.get(1);
                        sem_Rdc.get(1);
                        drive_rdata(q3.pop_front());
                        sem_Rdc.put(1);
                end
        join_any
  
endtask: drive

//===========================================================
    // AW channel
//===========================================================

task slave_driver::drive_awaddr(Axi3_trans xtn_wr);

        $display("start of slave awaddr channel");

        repeat ($urandom_range(1,5))
                @(vif.slv_drv_cb);

        vif.slv_drv_cb.AWREADY <= 1;

        @(vif.slv_drv_cb iff
         (vif.slv_drv_cb.AWVALID && vif.slv_drv_cb.AWREADY));

        //      xtn_wr.AResetn = vif.slv_drv_cb.AResetn;
        xtn_wr.AWID = vif.slv_drv_cb.AWID;
        xtn_wr.AWLEN = vif.slv_drv_cb.AWLEN;
        xtn_wr.AWSIZE = vif.slv_drv_cb.AWSIZE;
        xtn_wr.AWBURST = vif.slv_drv_cb.AWBURST;
        xtn_wr.AWADDR = vif.slv_drv_cb.AWADDR;
        xtn_wr.AWVALID = vif.slv_drv_cb.AWVALID;

        vif.slv_drv_cb.AWREADY <= 0;

        q1.push_back(xtn_wr);
        q2.push_back(xtn_wr);

        $display("end of slave awaddr channel");
        
endtask: drive_awaddr

//===========================================================
    // W channel
//===========================================================

task slave_driver::drive_wdata(Axi3_trans xtn_wr);

        $display("start of slave wdata channel");

        for(int i=0; i<=(xtn_wr.AWLEN); i=i+1)
                begin
                        vif.slv_drv_cb.WREADY <= 1;

                        @(vif.slv_drv_cb iff
                        (vif.slv_drv_cb.WVALID && vif.slv_drv_cb.WREADY));

                        xtn_wr.WID = vif.slv_drv_cb.WID;
                        xtn_wr.WDATA[i] = vif.slv_drv_cb.WDATA;
                        xtn_wr.WSTRB[i] = vif.slv_drv_cb.WSTRB;
                        xtn_wr.WVALID = vif.slv_drv_cb.WVALID;
                        xtn_wr.WLAST = vif.slv_drv_cb.WLAST;

                        vif.slv_drv_cb.WREADY <= 0;

                        repeat($urandom_range(1,5))
                                @(vif.slv_drv_cb);
                end
        $display("end of slave wdata channel");
        
endtask: drive_wdata

//===========================================================
    // B channel
//===========================================================

task slave_driver::drive_bresp(Axi3_trans xtn_wr);

        $display("start of slave bresp channel");

        vif.slv_drv_cb.BID <= xtn_wr.AWID;
        vif.slv_drv_cb.BVALID <= 1'b1;
        vif.slv_drv_cb.BRESP <= 2'b00; //okay

        @(vif.slv_drv_cb iff
        (vif.slv_drv_cb.BVALID && vif.slv_drv_cb.BREADY));

        vif.slv_drv_cb.BVALID <= 0;
        vif.slv_drv_cb.BRESP <= 'hx;

        repeat($urandom_range(1,5))
        @(vif.slv_drv_cb);

        $display("end of slave bresp channel");
        
endtask: drive_bresp

//===========================================================
    // AR channel
//===========================================================

task slave_driver::drive_raddr(Axi3_trans xtn_rd);

        $display("start of slave raddr channel");

        vif.slv_drv_cb.ARREADY <= 1'b0;

        // Random backpressure before accepting AR
        repeat ($urandom_range(1,5))
                @(vif.slv_drv_cb);

        vif.slv_drv_cb.ARREADY <= 1;

        @(vif.slv_drv_cb iff
        (vif.slv_drv_cb.ARVALID && vif.slv_drv_cb.ARREADY));

        xtn_rd.ARID = vif.slv_drv_cb.ARID;
        xtn_rd.ARLEN = vif.slv_drv_cb.ARLEN;
        xtn_rd.ARSIZE = vif.slv_drv_cb.ARSIZE;
        xtn_rd.ARBURST = vif.slv_drv_cb.ARBURST;
        xtn_rd.ARADDR = vif.slv_drv_cb.ARADDR;

        vif.slv_drv_cb.ARREADY <= 0;

        q3.push_back(xtn_rd);

        $display("end of slave raddr channel");
        
endtask: drive_raddr
          
//===========================================================
    // R channel
//===========================================================

task slave_driver::drive_rdata(Axi3_trans xtn_rd);

        $display("start of slave rdata channel");

        for(int i=0; i<=(xtn_rd.ARLEN); i=i+1)
        begin
                vif.slv_drv_cb.RID <= xtn_rd.ARID;
                vif.slv_drv_cb.RDATA <= $urandom;
                vif.slv_drv_cb.RVALID <= 1;
                vif.slv_drv_cb.RRESP <= 2'b00;

                if(i == (xtn_rd.ARLEN))
                begin
                        vif.slv_drv_cb.RLAST <= 1;
                end
                else begin
                        vif.slv_drv_cb.RLAST <= 0;
                end

                @(vif.slv_drv_cb iff
                (vif.slv_drv_cb.RVALID && vif.slv_drv_cb.RREADY));

                vif.slv_drv_cb.RVALID <= 0;
                vif.slv_drv_cb.RLAST <= 0;

                repeat($urandom_range(1,5))
                @(vif.slv_drv_cb);

        end

        $display("end of slave rdata channel");

endtask: drive_rdata
                

