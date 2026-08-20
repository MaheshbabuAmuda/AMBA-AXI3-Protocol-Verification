class Axi3_scoreboard extends uvm_scoreboard;

        `uvm_component_utils(Axi3_scoreboard)

        //Analysis FIFOs
        uvm_tlm_analysis_fifo#(Axi3_trans) mstr_fifo_h[];
        uvm_tlm_analysis_fifo#(Axi3_trans) slv_fifo_h[];

        // Environment Configuration
        Axi3_env_config env_cfg;

        // Transactions
        Axi3_trans mstr_xtn;
        Axi3_trans slv_xtn;
        Axi3_trans wr_xtn;
        Axi3_trans rd_xtn;

        //Scoreboard statistics
        int total_packets_recieved = 0;
        int total_packets_matched = 0;
        int total_packets_mismatched = 0;

        //Covergroups for coverage
        covergroup write_cg;

                option.per_instance = 1;

                //Write Address:
                awaddr_cp : coverpoint wr_xtn.AWADDR {
                        bins awaddr_bin = {
                                [32'h0000_0000:32'hFFFF_FFFF]
                        };
                }

                awid_cp : coverpoint wr_xtn.AWID {
                        bins ids[] = {[0:15]};
                }

                awburst_cp: coverpoint wr_xtn.AWBURST {
                        bins FIXED = {2'b00};
                        bins INCR  = {2'b01};
                        bins WRAP  = {2'b10};
                }

                awsize_cp : coverpoint wr_xtn.AWSIZE {
                        bins awsize_bin[] = {[0:2]};
                }

               awlen_cp : coverpoint wr_xtn.AWLEN {
                        bins awlen[] = {[0:7]};
                }

                //Write Response:
                bresp_cp  : coverpoint wr_xtn.BRESP{ bins bresp_bin = {0}; }

                WRITE_ADDRESS_CROSS : cross awburst_cp, awsize_cp, awlen_cp
                {
                    // WRAP burst is legal only for AWLEN = 1,3,7,15
                    ignore_bins illegal_wrap_len =
                        binsof(awburst_cp) intersect {2'b10} &&
                        binsof(awlen_cp) intersect {0,2,4,5,6};
                }
          
        endgroup

        covergroup write_cg1 with function sample(int i);
                option.per_instance = 1;

                //Write Srrobe:
                        wstrb_cp : coverpoint wr_xtn.WSTRB[i] {
                                bins wstrb0 = {4'b1111};
                                bins wstrb1 = {4'b1100};
                                bins wstrb2 = {4'b0011};
                                bins wstrb3 = {4'b1000};
                                bins wstrb4 = {4'b0100};
                                bins wstrb5 = {4'b0010};
                                bins wstrb6 = {4'b0001};
                                bins wstrb7 = {4'b1110};
                        }
        endgroup

        //Read Address:
        covergroup read_cg;
                option.per_instance = 1;

                araddr_cp : coverpoint rd_xtn.ARADDR {
                    bins araddr_bin = {
                        [32'h0000_0000 : 32'hFFFF_FFFF]
                    };
                }

                arid_cp : coverpoint rd_xtn.ARID {
                    bins ids[] = {[0:15]};
                }

                arburst_cp : coverpoint rd_xtn.ARBURST {
                    bins FIXED = {2'b00};
                    bins INCR  = {2'b01};
                    bins WRAP  = {2'b10};
                }


                arsize_cp : coverpoint rd_xtn.ARSIZE {
                    bins arsize_bin[] = {[0:2]};
                }
          
                arlen_cp : coverpoint rd_xtn.ARLEN {
                    bins arlen[] = {[0:7]};
                }

                READ_BURST_CROSS : cross arburst_cp, arsize_cp, arlen_cp {
                            ignore_bins illegal_wrap_len =
                                binsof(arburst_cp) intersect {2'b10} &&
                                binsof(arlen_cp) intersect {0,2,4,5,6,8,9,10,11,12,13,14};
                }

        endgroup

        covergroup read_cg1 with function sample(bit [1:0] rresp);
                option.per_instance = 1;
                //Read Response:
                        rresp_cp  : coverpoint rresp{ bins rresp_bin = {0}; }
        endgroup

extern function new(string name = "Axi3_scoreboard", uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void report_phase(uvm_phase phase);

endclass

function Axi3_scoreboard::new(string name = "Axi3_scoreboard", uvm_component parent);

        super.new(name,parent);

                write_cg  = new();
                write_cg1 = new();
                read_cg   = new();
                read_cg1  = new();

endfunction: new

function void Axi3_scoreboard::build_phase(uvm_phase phase);

   super.build_phase(phase);

        if(!uvm_config_db #(Axi3_env_config)::get(this,"","Axi3_env_config",env_cfg))
        `uvm_fatal(get_type_name(), "Cannot get Axi3_env_config, Have u set() it?")

        mstr_fifo_h = new[env_cfg.no_of_master_agents];
        slv_fifo_h  = new[env_cfg.no_of_slave_agents];

        foreach(mstr_fifo_h[i]) begin
                mstr_fifo_h[i] = new($sformatf("mstr_fifo_h[%0d]",i), this);
        end

        foreach(slv_fifo_h[i]) begin
                slv_fifo_h[i] = new($sformatf("slv_fifo_h[%0d]",i), this);
        end

endfunction: build_phase

task Axi3_scoreboard::run_phase(uvm_phase phase);

    forever begin

        // Get transactions
        mstr_fifo_h[0].get(mstr_xtn);
        slv_fifo_h[0].get(slv_xtn);

         total_packets_recieved++;

        //Compare
        if (mstr_xtn.compare(slv_xtn)) begin
                total_packets_matched++;
                `uvm_info("SCOREBOARD", "MASTER and SLAVE transactions MATCH", UVM_LOW)
        end

        else begin
                total_packets_mismatched++;
                `uvm_error("SCOREBOARD", "MASTER and SLAVE transactions MISMATCH")
        end

        if (mstr_xtn.AWVALID) begin

                wr_xtn = mstr_xtn;
                write_cg.sample();

                if (wr_xtn.WSTRB.size() > 0) begin

                        for (int i = 0; i < wr_xtn.WSTRB.size(); i++) begin

                                 write_cg1.sample(i);

                        end

                end

                else begin

                        `uvm_error("WSTRB_COV", "WSTRB array is empty")

                end
        end

        else if (mstr_xtn.ARVALID) begin

                rd_xtn = mstr_xtn;

                read_cg.sample();

                if (rd_xtn.RRESP.size() > 0) begin

                        read_cg1.sample(rd_xtn.RRESP[0]);

                end

                else begin

                    `uvm_error("RRESP_COV", "RRESP array is EMPTY")

                end

        end

   end

endtask: run_phase

function void Axi3_scoreboard::report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(get_type_name(), "==========================================", UVM_NONE)

        `uvm_info(get_type_name(), $sformatf(" Total Packets Received / Compared : %0d", total_packets_recieved), UVM_LOW)

        `uvm_info(get_type_name(), $sformatf(" Total Packets Matched             : %0d", total_packets_matched), UVM_LOW)

        `uvm_info(get_type_name(), $sformatf(" Total Packets Mismatched          : %0d", total_packets_mismatched), UVM_LOW)

        `uvm_info(get_type_name(), "==========================================", UVM_NONE)

endfunction: report_phase



