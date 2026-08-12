class master_driver extends uvm_driver #(Axi3_trans);

        `uvm_component_utils(master_driver)

        virtual Axi3_if.MDRV vif;

        master_agent_config m_cfg;

        Axi3_trans xtn; 
        Axi3_trans q1[$], q2[$], q3[$], q4[$], q5[$];

        Axi3_trans write_outstanding[int];
        Axi3_trans read_outstanding[int];

        semaphore sem_Wac = new(1); //write addr channel
        semaphore sem_Wdc = new(1); //write data channel
        semaphore sem_Wrc = new(1); //write resp channel
        semaphore sem_Wddc = new(); //write data dependency channel
        semaphore sem_Wrdc = new(); //write resp dependency channel

        semaphore sem_Rac = new(1); //read addr channel
        semaphore sem_Rdc = new(1); //read data channel
        semaphore sem_Rddc = new(); //read data dependency channel

          // Semaphore for outstanding tables

            semaphore sem_wr_table = new(1);
            semaphore sem_rd_table = new(1);

        extern function new(string name = "master_driver", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);
        extern task drive(Axi3_trans xtn);

        extern task drive_awaddr(Axi3_trans xtn);
        extern task drive_wdata(Axi3_trans xtn);
        extern task drive_bresp(Axi3_trans xtn);

        extern task drive_raddr(Axi3_trans xtn);
        extern task drive_rdata(Axi3_trans xtn);

endclass
function master_driver::new(string name = "master_driver", uvm_component parent);
        super.new(name,parent);
endfunction

function void master_driver::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(master_agent_config)::get(this, "" , "master_agent_config" , m_cfg ))
        `uvm_fatal("MASTER_CONFIG", "cannot get(), HAve u set () master_agent_config ?")
endfunction

function void master_driver::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vif = m_cfg.vif;

endfunction

task master_driver::run_phase(uvm_phase phase);
        super.run_phase(phase);
                forever
                        begin
                                seq_item_port.get_next_item(req);
                                req.print();
                                drive(req);
                        //      #5000;
                                seq_item_port.item_done();

                        end
endtask

task master_driver::drive(Axi3_trans xtn);

  if (xtn.kind == WRITE) begin

        q1.push_back(xtn);
        q2.push_back(xtn);
        q3.push_back(xtn);

        fork       //parallel execution construct
                begin
                        //write_address_channel:
                        sem_Wac.get(1);         //write addr semaphore
                        drive_awaddr(q1.pop_front());
                        sem_Wddc.put(1);        //write data dependency

                        sem_Wac.put(1);         //releasing the key
                end

                begin
                        //write_data_channel:
                        sem_Wddc.get(1);        //getting key from addr channel
                        sem_Wdc.get(1);         //write data semaphore
                        drive_wdata(q2.pop_front());
                        sem_Wdc.put(1);         //releasing the key of data channel

                        sem_Wrdc.put(1);        //write responce dependency
                end

                begin
                        //write_response channel:
                        sem_Wrdc.get(1);        //getting key from data channel
                        sem_Wrc.get(1);         //write response semaphore
                        drive_bresp(q3.pop_front());
                        sem_Wrc.put(1);
                end
        join_any
  end

  else begin

        q4.push_back(xtn);
        q5.push_back(xtn);

        fork
                begin
                        //read address channel:
                        sem_Rac.get(1);
                        drive_raddr(q4.pop_front());
                        sem_Rac.put(1);

                        sem_Rddc.put(1);
                end

                begin
                        //read data channel:
                        sem_Rddc.get(1);
                        sem_Rdc.get(1);
                        drive_rdata(q5.pop_front());
                        sem_Rdc.put(1);
                end
        join_any
  end

endtask

//===========================================================
    // Drive AW channel
//===========================================================

task master_driver::drive_awaddr(Axi3_trans xtn);

        $display("MASTER: Driving WRITE ADDRESS");

        vif.mstr_drv_cb.AWVALID <=1;

        vif.mstr_drv_cb.AWADDR <= xtn.AWADDR;
        vif.mstr_drv_cb.AWSIZE <= xtn.AWSIZE;
        vif.mstr_drv_cb.AWLEN <= xtn.AWLEN;
        vif.mstr_drv_cb.AWBURST <= xtn.AWBURST;
        vif.mstr_drv_cb.AWID <= xtn.AWID;

        do begin
                @(vif.mstr_drv_cb);
        end
        while(!vif.mstr_drv_cb.AWREADY); // Wait for AW handshake
        vif.mstr_drv_cb.AWVALID <= 0;

//===========================================================
    // Store transaction in outstanding WRITE table
    // AWID -> transaction
//===========================================================

    sem_wr_table.get(1);

    if (write_outstanding.exists(xtn.AWID)) begin

        `uvm_error("MASTER_DRIVER", $sformatf("Duplicate outstanding AWID = %0d", xtn.AWID))

    end
    else begin

        write_outstanding[xtn.AWID] = xtn;

        `uvm_info("OUTSTANDING", $sformatf("WRITE transaction added: AWID=%0d", xtn.AWID), UVM_MEDIUM)

    end

    sem_wr_table.put(1);


        repeat($urandom_range(1,5))
                @(vif.mstr_drv_cb);

        $display("MASTER Driver: End of WRITE ADDRESS");
endtask

//=======================================================
        // Drive W channel
//=======================================================

task master_driver::drive_wdata(Axi3_trans xtn);


        $display("MASTER: Driving WRITE DATA");

    for (int i = 0; i < xtn.WDATA.size(); i++)
      begin

        vif.mstr_drv_cb.WVALID <= 1;
        vif.mstr_drv_cb.WDATA  <= xtn.WDATA[i];
        vif.mstr_drv_cb.WSTRB  <= xtn.WSTRB[i];
        vif.mstr_drv_cb.WID    <= xtn.WID;

        if (i == xtn.AWLEN)
            vif.mstr_drv_cb.WLAST <= 1;
        else
            vif.mstr_drv_cb.WLAST <= 0;

         do begin
            @(vif.mstr_drv_cb);
        end
        while (!vif.mstr_drv_cb.WREADY);

        vif.mstr_drv_cb.WVALID <= 0;
        vif.mstr_drv_cb.WLAST  <= 0;

        repeat ($urandom_range(1,5))
            @(vif.mstr_drv_cb);

    end

    $display("MASTER Driver: End of WRITE DATA");

endtask

//=======================================================
        // Drive B channel
//=======================================================

task master_driver::drive_bresp(Axi3_trans xtn);

        $display("MASTER: Waiting for WRITE RESPONSE");

        vif.mstr_drv_cb.BREADY <= 1;

        do begin
           @(vif.mstr_drv_cb);
        end
        while (!vif.mstr_drv_cb.BVALID);

 // Capture BID

        bid = vif.mstr_drv_cb.BID;
        $display("MASTER: BRESP received");

        $display("BID   = %0d",vif.mstr_drv_cb.BID);

        $display("BRESP = %0d",vif.mstr_drv_cb.BRESP);

// Deassert BREADY
        vif.mstr_drv_cb.BREADY <= 0;

// Find transaction using BID
    sem_wr_table.get(1);

    if (!write_outstanding.exists(bid)) begin

        `uvm_error("MASTER_DRIVER",$sformatf("Received BID=%0d but no matching outstanding WRITE exists",bid))

    end
    else begin

        `uvm_info("OUTSTANDING",$sformatf("WRITE transaction completed: BID=%0d",bid),UVM_MEDIUM);

        // Remove completed transaction

        write_outstanding.delete(bid);

    end

        sem_wr_table.put(1);

        repeat($urandom_range(1,5))
        @(vif.mstr_drv_cb);

        $display("MASTER-Driver: End WRITE RESPONSE");

endtask

//===========================================================
    // Drive AR channel
//===========================================================
task master_driver::drive_raddr(Axi3_trans xtn);

        $display("MASTER: Driving READ ADDRESS");

        vif.mstr_drv_cb.ARVALID <=1;
        vif.mstr_drv_cb.ARADDR <= xtn.ARADDR;
        vif.mstr_drv_cb.ARSIZE <= xtn.ARSIZE;
        vif.mstr_drv_cb.ARLEN <= xtn.ARLEN;
        vif.mstr_drv_cb.ARBURST <= xtn.ARBURST;
        vif.mstr_drv_cb.ARID <= xtn.ARID;

        do begin
        @(vif.mstr_drv_cb);
        end
        while (!vif.mstr_drv_cb.ARREADY);

        vif.mstr_drv_cb.ARVALID <= 0;
// Store transaction
// ARID -> transaction
        sem_rd_table.get(1);

    if (read_outstanding.exists(xtn.ARID)) begin

        `uvm_error("MASTER_DRIVER", $sformatf("Duplicate outstanding ARID = %0d", xtn.ARID))

    end
    else begin

        read_outstanding[xtn.ARID] = xtn;

        `uvm_info("OUTSTANDING", $sformatf("READ transaction added: ARID=%0d", xtn.ARID), UVM_MEDIUM)
    end

        sem_rd_table.put(1);

    repeat ($urandom_range(1,5))
        @(vif.mstr_drv_cb);

    $display("MASTER: End READ ADDRESS");

endtask
          
//===========================================================
    // Drive AR channel
//===========================================================

  task master_driver::drive_rdata(Axi3_trans xtn);

        int rid;
        int beat_count = 0;
        $display("MASTER: Waiting for READ DATA");

    forever begin

/*      for(int i = 0; i < (xtn.ARLEN+1); i++)  ///ARLEN is the index of the last beat, not the number of beats.
         begin
                vif.mstr_drv_cb.RREADY <=1;
                @(vif.mstr_drv_cb);
                wait(vif.mstr_drv_cb.RVALID);

                vif.mstr_drv_cb.RREADY <=0;

                repeat($urandom_range(1,5))
                @(vif.mstr_drv_cb);
         end
*/
         vif.mstr_drv_cb.RREADY <= 1;
        do begin
            @(vif.mstr_drv_cb);
        end
        while (!vif.mstr_drv_cb.RVALID);
        // Capture RID
        rid = vif.mstr_drv_cb.RID;
        beat_count++;
        // Display received R channel information
        $display("MASTER: RDATA received");
        $display("RID   = %0d",vif.mstr_drv_cb.RID);
        $display("RDATA = %0h",vif.mstr_drv_cb.RDATA);
        $display("RRESP = %0d",vif.mstr_drv_cb.RRESP);
        $display("RLAST = %0d",vif.mstr_drv_cb.RLAST);
        // Check last beat
        if (vif.mstr_drv_cb.RLAST) begin
            // Deassert RREADY
            vif.mstr_drv_cb.RREADY <= 0;
            // Find transaction using RID
            sem_rd_table.get(1);

            if (!read_outstanding.exists(rid)) begin
                `uvm_error("MASTER_DRIVER",$sformatf("Received RID=%0d but no matching outstanding READ exists",rid))
            end
            else begin
                `uvm_info("OUTSTANDING",$sformatf("READ transaction completed: RID=%0d, beats=%0d",rid,beat_count),UVM_MEDIUM);
                // Remove completed transaction
                read_outstanding.delete(rid);
            end
            sem_rd_table.put(1);
            break;
        end
        // Delay before next R beat
        repeat ($urandom_range(1,5))
            @(vif.mstr_drv_cb);
    end

    $display("MASTER: End READ DATA");

endtask
