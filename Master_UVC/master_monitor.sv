class master_monitor extends uvm_monitor;

        `uvm_component_utils(master_monitor)

        virtual Axi3_if.MMON vif;

        master_agent_config m_cfg;

        uvm_analysis_port #(Axi3_trans) monitor_port;

        Axi3_trans xtn1, xtn_wr, xtn_rd;

        Axi3_trans q1[$], q2[$], q3[$];
        
        // Outstanding transaction tables
        /*Axi3_trans write_outstanding[int];
        Axi3_trans read_outstanding[int];*/

        semaphore sem_Wac = new(1); //write addr channel
        semaphore sem_Wdc = new(1); //write data channel
        semaphore sem_Wrc = new(1); //write resp channel
        semaphore sem_Wddc = new(); //write data dependency channel
        semaphore sem_Wrdc = new(); //write resp dependency channel

        semaphore sem_Rac = new(1); //read addr channel
        semaphore sem_Rdc = new(1); //read data channel
        semaphore sem_Rddc = new(); //read data dependency channel

            // Semaphores for outstanding tables
               /* semaphore sem_wr_table = new(1);
                semaphore sem_rd_table = new(1);*/

        extern function new(string name = "master_monitor", uvm_component parent);
        extern function void build_phase(uvm_phase phase);
        extern function void connect_phase(uvm_phase phase);
        extern task run_phase(uvm_phase phase);

        extern task mstr_collect();
        extern task collect_awaddr(Axi3_trans xtn_wr);
        extern task collect_wdata(Axi3_trans xtn_wr);
        extern task collect_bresp(Axi3_trans xtn_wr);

        extern task collect_raddr(Axi3_trans xtn_rd);
        extern task collect_rdata(Axi3_trans xtn_rd);

endclass

function master_monitor::new(string name = "master_monitor", uvm_component parent);
        super.new(name, parent);

        monitor_port = new("monitor_port", this);

endfunction: new

function void  master_monitor::build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(master_agent_config)::get(this, "", "master_agent_config", m_cfg))
        `uvm_fatal("MASTER_CONFIG", "cannot get(), Have u set() master_agent_config ?")

endfunction: build_phase

function void master_monitor::connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vif = m_cfg.vif;

endfunction: connect_phase

task master_monitor::run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
                mstr_collect();
        end

endtask: run_phase

task master_monitor::mstr_collect();

        xtn_wr = Axi3_trans::type_id::create("xtn_wr");
        xtn_rd = Axi3_trans::type_id::create("xtn_rd");

        fork
                begin
                        sem_Wac.get(1);
                        collect_awaddr(xtn_wr);
                        sem_Wac.put(1);
                        sem_Wddc.put(1);
                end

                begin
                        sem_Wdc.get(1);
                        sem_Wddc.get(1);
                        collect_wdata(q1.pop_front());
                        sem_Wdc.put(1);
                        sem_Wrdc.put(1);
                end

                begin
                        sem_Wrc.get(1);
                        sem_Wrdc.get(1);
                        collect_bresp(q2.pop_front());
                        sem_Wrc.put(1);
                end

                begin
                        sem_Rac.get(1);
                        collect_raddr(xtn_rd);
                        sem_Rac.put(1);
                        sem_Rddc.put(1);
                end

                begin
                        sem_Rdc.get(1);
                        sem_Rddc.get(1);
                        collect_rdata(q3.pop_front());
                        sem_Rdc.put(1);
                end
        join_any
        
endtask: mstr_collect

//===========================================================
    //Monitor AW channel
//===========================================================

task master_monitor::collect_awaddr(Axi3_trans xtn_wr);

       // int awid;

        $display("Monitoring master AWADDR channel");

    // Samples signals exactly at the clocking block event.
    // If the condition is false, it ignores that clock edge and waits for the next one.
    // Proceeds only when both AWVALID and AWREADY are asserted (AXI write address handshake).
        @(vif.mstr_mon_cb iff (vif.mstr_mon_cb.AWVALID && vif.mstr_mon_cb.AWREADY));
        //wait( (vif.mstr_mon_cb.AWVALID) && (vif.mstr_mon_cb.AWREADY));

        xtn_wr.AWVALID = vif.mstr_mon_cb.AWVALID;
        xtn_wr.AWADDR  = vif.mstr_mon_cb.AWADDR;
        xtn_wr.AWSIZE  = vif.mstr_mon_cb.AWSIZE;
        xtn_wr.AWID    = vif.mstr_mon_cb.AWID;
        xtn_wr.AWLEN   = vif.mstr_mon_cb.AWLEN;
        xtn_wr.AWBURST = vif.mstr_mon_cb.AWBURST;
        
        q1.push_back(xtn_wr);
        q2.push_back(xtn_wr);
        
  /*    awid = xtn_wr.AWID;
    // Store in outstanding WRITE table
    // AWID -> transaction
    sem_wr_table.get(1);

    if (write_outstanding.exists(awid)) begin
        `uvm_error("MASTER_MONITOR",$sformatf("Duplicate outstanding AWID = %0d",awid))
    end
    else begin
        write_outstanding[awid] = xtn_wr;
        `uvm_info("OUTSTANDING",$sformatf("WRITE added: AWID=%0d",awid),UVM_MEDIUM)
    end

    sem_wr_table.put(1);
    */
        
        `uvm_info(get_type_name(),$sformatf("From Mstr_Mon: Collected AWADDR:\n%s", xtn_wr.sprint()), UVM_MEDIUM)

    $display("End of master monitor AWADDR channel");

endtask: collect_awaddr

//===========================================================
    //Monitor W channel
//===========================================================

task master_monitor::collect_wdata(Axi3_trans xtn_wr);

    int i;

    $display("Monitoring master WDATA channel");

    xtn1 = Axi3_trans::type_id::create("xtn1");

    // Copy AW transaction
    xtn1 = xtn_wr;

    // Calculate write addresses
    xtn1.cal_addr();

    xtn_wr.WDATA = new[xtn_wr.AWLEN + 1];
    xtn_wr.WSTRB = new[xtn_wr.AWLEN + 1];

     foreach (xtn1.WDATA[i]) begin

        @(vif.mstr_mon_cb iff (vif.mstr_mon_cb.WVALID && vif.mstr_mon_cb.WREADY));
        //iff -  Wait for a clocking block event and proceed only when both WVALID and WREADY

        xtn_wr.WID      = vif.mstr_mon_cb.WID;
        xtn_wr.WDATA[i] = vif.mstr_mon_cb.WDATA;
        xtn_wr.WSTRB[i] = vif.mstr_mon_cb.WSTRB;

        if (i == xtn_wr.AWLEN)
            xtn_wr.WLAST = vif.mstr_mon_cb.WLAST;

    end

    `uvm_info(get_type_name(),$sformatf("From Mstr_Mon: Collected WDATA:\n%s", xtn_wr.sprint()),
              UVM_MEDIUM)

    $display("End of master monitor WDATA channel");

endtask

task master_monitor::collect_bresp(Axi3_trans xtn_wr);

    int bid;
    Axi3_trans completed_xtn;
    $display("Monitoring master BRESP channel");

    @(vif.mstr_mon_cb iff (vif.mstr_mon_cb.BVALID && vif.mstr_mon_cb.BREADY));

    xtn_wr.BID   = vif.mstr_mon_cb.BID;
    xtn_wr.BRESP = vif.mstr_mon_cb.BRESP;

        bid = vif.mstr_mon_cb.BID;
// Find transaction using BID
    sem_wr_table.get(1);

    if (!write_outstanding.exists(bid)) begin
        `uvm_error("MASTER_MONITOR", $sformatf("Received BID=%0d but no matching outstanding WRITE exists",bid))
    end
    else begin
        completed_xtn =  write_outstanding[bid];

        //=======================================================
        // Update response
        //=======================================================

        completed_xtn.BID = vif.mstr_mon_cb.BID;

        completed_xtn.BRESP = vif.mstr_mon_cb.BRESP;

    //monitor_port.write(xtn_wr);
   // m_cfg.mstr_xtn_cnt++;

         // Send complete transaction
        monitor_port.write(completed_xtn);
        m_cfg.mstr_xtn_cnt++;
        `uvm_info("MASTER_MONITOR",$sformatf("COMPLETE WRITE:\n%s",completed_xtn.sprint()),UVM_MEDIUM)

        // Delete completed transaction
        write_outstanding.delete(bid);
    end

    sem_wr_table.put(1);

    $display("End of master monitor BRESP channel");

endtask

task master_monitor::collect_raddr(Axi3_trans xtn_rd);

  //   int arid;

    $display("Monitoring master RADDR channel");

    @(vif.mstr_mon_cb iff (vif.mstr_mon_cb.ARVALID && vif.mstr_mon_cb.ARREADY));

    xtn_rd.ARVALID = vif.mstr_mon_cb.ARVALID;
    xtn_rd.ARADDR  = vif.mstr_mon_cb.ARADDR;
    xtn_rd.ARSIZE  = vif.mstr_mon_cb.ARSIZE;
    xtn_rd.ARID    = vif.mstr_mon_cb.ARID;
    xtn_rd.ARLEN   = vif.mstr_mon_cb.ARLEN;
    xtn_rd.ARBURST = vif.mstr_mon_cb.ARBURST;
//      arid = xtn_rd.ARID;
    q3.push_back(xtn_rd);

     // Store in outstanding table
/*    sem_rd_table.get(1);

    if (read_outstanding.exists(arid)) begin
        `uvm_error("MASTER_MONITOR",$sformatf("Duplicate outstanding ARID=%0d", arid))
    end
    else begin
        read_outstanding[arid] = xtn_rd;
        `uvm_info("OUTSTANDING",$sformatf("READ added: ARID=%0d",arid),UVM_MEDIUM)
    end

    sem_rd_table.put(1);
*/
//    monitor_port.write(xtn_rd);
//    m_cfg.mstr_xtn_cnt++;

    `uvm_info(get_type_name(),$sformatf("From Mstr_Mon: Collected RADDR:\n%s",xtn_rd.sprint()), UVM_MEDIUM)

    $display("End of master monitor RADDR channel");

endtask

task master_monitor::collect_rdata(Axi3_trans xtn_rd);

    $display("Monitoring master RDATA channel");

    xtn_rd.RDATA = new[xtn_rd.ARLEN + 1];
    xtn_rd.RRESP = new[xtn_rd.ARLEN + 1];

    for (int i = 0; i <= xtn_rd.ARLEN; i++) begin

        @(vif.mstr_mon_cb iff (vif.mstr_mon_cb.RVALID && vif.mstr_mon_cb.RREADY));

        xtn_rd.RID      = vif.mstr_mon_cb.RID;
        xtn_rd.RVALID   = vif.mstr_mon_cb.RVALID;
        xtn_rd.RREADY   = vif.mstr_mon_cb.RREADY;
        xtn_rd.RDATA[i] = vif.mstr_mon_cb.RDATA;
        xtn_rd.RRESP[i] = vif.mstr_mon_cb.RRESP;

        if (i == xtn_rd.ARLEN)
            xtn_rd.RLAST = vif.mstr_mon_cb.RLAST;

        $display("RID   = %0d", vif.mstr_mon_cb.RID);
        $display("RDATA = %0h", vif.mstr_mon_cb.RDATA);
        $display("RRESP = %0d", vif.mstr_mon_cb.RRESP);
        $display("RLAST = %0b", vif.mstr_mon_cb.RLAST);

    end

    //=======================================================
    // Send complete READ transaction
    //=======================================================

    monitor_port.write(xtn_rd);

    m_cfg.mstr_xtn_cnt++;

    `uvm_info("MASTER_MONITOR", $sformatf("COMPLETE READ:\n%s",xtn_rd.sprint()),UVM_MEDIUM)

    $display("MASTER MONITOR: End RDATA channel");

endtask

