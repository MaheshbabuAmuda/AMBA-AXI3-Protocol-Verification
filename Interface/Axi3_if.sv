interface Axi3_if(input bit AClk);

logic ARESETn;

//write address channel (AW):

logic [31:0] AWADDR;
logic [7:0] AWLEN;
logic [2:0] AWSIZE;
logic [1:0] AWBURST;
logic [3:0] AWID;
logic [1:0] AWLOCK;
logic [3:0] AWCACHE;
logic [2:0] AWPROT;
logic AWVALID, AWREADY;

//write data channel (W):

logic [3:0] WID;
logic [31:0] WDATA;
logic [3:0] WSTRB;
logic WLAST, WVALID, WREADY;

//write Response channel (B):

logic [3:0] BID;
logic [1:0] BRESP;
logic BVALID, BREADY;

//read address channel (AR):

logic [31:0] ARADDR;
logic [7:0] ARLEN;
logic [2:0] ARSIZE;
logic [1:0] ARBURST;
logic [3:0] ARID;
logic [1:0] ARLOCK;
logic [3:0] ARCACHE;
logic [2:0] ARPROT;
logic ARVALID, ARREADY;

//read data channel (R):

logic [31:0] RDATA;
logic [3:0] RID;
logic [1:0] RRESP;
logic RLAST, RVALID, RREADY;
        

//cb for master driver:

clocking mstr_drv_cb @(posedge AClk);

        default input #1 output #1;

output ARESETn,  AWADDR, AWLEN, AWSIZE, AWBURST, AWID, AWLOCK, AWCACHE, AWPROT, AWVALID;
input AWREADY;

output WID, WDATA, WSTRB, WLAST, WVALID;
input WREADY;

output BREADY;
input BID, BRESP, BVALID;

output ARADDR, ARLEN, ARSIZE, ARBURST, ARID, ARLOCK, ARCACHE, ARPROT, ARVALID;
input ARREADY;

output RREADY;
input RDATA, RID, RRESP, RVALID, RLAST;

endclocking

//cb for master monitor:
        
clocking mstr_mon_cb @(posedge AClk);

        default input #1 output #1;
        
input ARESETn, AWADDR, AWLEN, AWSIZE, AWBURST, AWID, AWLOCK, AWCACHE, AWPROT, AWVALID, AWREADY;

input WID, WDATA, WSTRB, WLAST, WVALID, WREADY;

input BREADY, BID, BRESP, BVALID;

input ARADDR, ARLEN, ARSIZE, ARBURST, ARID, ARLOCK, ARCACHE, ARPROT, ARVALID, ARREADY;

input RREADY, RDATA, RID, RRESP,  RVALID, RLAST;

endclocking

//cb for slave driver:

clocking slv_drv_cb @(posedge AClk);

        default input #1 output #1;

input ARESETn, AWADDR, AWLEN, AWSIZE, AWBURST, AWID, AWLOCK, AWCACHE, AWPROT, AWVALID;
output AWREADY;

input WID, WDATA, WSTRB, WLAST, WVALID;
output WREADY;

input BREADY;
output BID, BRESP, BVALID;

input ARADDR, ARLEN, ARSIZE, ARBURST, ARID, ARLOCK, ARCACHE, ARPROT, ARVALID;
output ARREADY;

input RREADY;
output RDATA, RVALID, RID, RRESP, RLAST;

endclocking

// cb for slave monitor:

clocking slv_mon_cb @(posedge AClk);

        default input #1 output #1;

input ARESETn, AWADDR, AWLEN, AWSIZE, AWBURST, AWID, AWLOCK, AWCACHE, AWPROT, AWVALID, AWREADY;

input WID, WDATA, WSTRB, WLAST, WVALID, WREADY;

input BREADY, BID, BRESP, BVALID;

input ARADDR, ARLEN, ARSIZE, ARBURST, ARID, ARLOCK, ARCACHE, ARPROT, ARVALID, ARREADY;

input RREADY, RDATA, RID, RRESP, RVALID, RLAST;

endclocking

//==============================================================
// ASSERTIONS
//==============================================================
        
//===============================================
         // WRITE ADDRESS CHANNEL (AR) :
//===============================================
        
// AWVALID must remain HIGH until AWREADY
        
property awvalid_wait_awready;
        @(posedge AClk) disable iff (!ARESETn) AWVALID && !AWREADY |=> AWVALID;
endproperty

assert property (awvalid_wait_awready)
    else $error("AXI3: AWVALID deasserted before AWREADY");

// AW signals must remain stable while waiting for AWREADY
        
property awaddr_signal_stable;
        @(posedge AClk) disable iff (!ARESETn)
        AWVALID && !AWREADY |=> AWVALID  &&  $stable(AWID)  &&  $stable(AWADDR)  &&  $stable(AWLEN)  &&  $stable(AWSIZE)  &&  $stable(AWBURST)
        until_with AWREADY;
endproperty

assert property (awaddr_signal_stable)
    else $error("AXI3: AWADDR/control signals changed before AWREADY");

// AWBURST = 2'b11 is reserved
        
property write_burst_reserved;
        @(posedge AClk) disable iff (!ARESETn) AWVALID |-> (AWBURST != 2'b11);
endproperty

assert property (write_burst_reserved)
    else $error("AXI3: Reserved AWBURST value detected");


// AWSIZE must be valid for a 32-bit data bus
        
property awsize_valid;
        @(posedge AClk) disable iff (!ARESETn) AWVALID |-> (AWSIZE inside {[0:2]});
endproperty

assert property (awsize_valid)
    else $error("AXI3: Invalid AWSIZE = %0d", AWSIZE);

// WRAP burst must have legal length
        
property awlen_for_wrap;
        @(posedge AClk) disable iff (!ARESETn) AWVALID && (AWBURST == 2'b10)  |->  (AWLEN inside {8'd1, 8'd3, 8'd7, 8'd15});
endproperty

assert property (awlen_for_wrap)
    else $error("AXI3: Invalid AWLEN=%0d for WRAP burst", AWLEN);

//=======================================
        // WRITE DATA CHANNEL (W):
//=======================================

// WVALID must remain HIGH until WREADY
        
property wvalid_wait_wready;
        @(posedge AClk) disable iff (!ARESETn) WVALID && !WREADY |=> WVALID;
endproperty

assert property (wvalid_wait_wready)
    else $error("AXI3: WVALID deasserted before WREADY");

// WDATA/WSTRB/WID/WLAST must remain stable
        
property wdata_signal_stable;
        @(posedge AClk) disable iff (!ARESETn) WVALID && !WREADY |=> WVALID &&  $stable(WID)  &&  $stable(WDATA)  &&  $stable(WSTRB) &&  $stable(WLAST)
        until_with WREADY;
endproperty

assert property (wdata_signal_stable)
    else $error("AXI3: WDATA/WSTRB/WID/WLAST changed before WREADY");

// WLAST must occur with WVALID
        
property wlast_with_wvalid;
        @(posedge AClk) disable iff (!ARESETn) WLAST |-> WVALID;
endproperty

assert property (wlast_with_wvalid)
    else $error("AXI3: WLAST asserted without WVALID");

//============================================
        // WRITE RESPONSE CHANNEL (B):
//============================================

// BVALID must remain HIGH until BREADY
        
property bvalid_wait_bready;
        @(posedge AClk) disable iff (!ARESETn) BVALID && !BREADY |=> BVALID;
endproperty

assert property (bvalid_wait_bready)
    else $error("AXI3: BVALID deasserted before BREADY");

// BID/BRESP must remain stable
        
property bresp_signal_stable;
        @(posedge AClk) disable iff (!ARESETn) BVALID && !BREADY |=> BVALID && $stable(BID) && $stable(BRESP)
        until_with BREADY;
endproperty

assert property (bresp_signal_stable)
    else $error("AXI3: BID/BRESP changed before BREADY");

//===========================================
        // READ ADDRESS CHANNEL (AR):
//===========================================

// ARVALID must remain HIGH until ARREADY
        
property arvalid_wait_arready;
        @(posedge AClk) disable iff (!ARESETn) ARVALID && !ARREADY |=> ARVALID;
endproperty

assert property (arvalid_wait_arready)
    else $error("AXI3: ARVALID deasserted before ARREADY");

// AR signals must remain stable
        
property araddr_signal_stable;
        @(posedge AClk) disable iff (!ARESETn) 
        ARVALID && !ARREADY |=> ARVALID && $stable(ARID) && $stable(ARADDR) && $stable(ARLEN) && $stable(ARSIZE) && $stable(ARBURST)
        until_with ARREADY;
endproperty

assert property (araddr_signal_stable)
    else $error("AXI3: ARADDR/control signals changed before ARREADY");


// ARBURST = 2'b11 is reserved
        
property read_burst_reserved;
        @(posedge AClk) disable iff (!ARESETn) ARVALID |-> (ARBURST != 2'b11);
endproperty

assert property (read_burst_reserved)
    else $error("AXI3: Reserved ARBURST value detected");


// ARSIZE must be valid
        
property arsize_valid;
        @(posedge AClk) disable iff (!ARESETn) ARVALID |-> (ARSIZE inside {[0:2]});
endproperty

assert property (arsize_valid)
    else $error("AXI3: Invalid ARSIZE = %0d", ARSIZE);

// WRAP burst length
        
property arlen_for_wrap;
        @(posedge AClk) disable iff (!ARESETn) ARVALID && (ARBURST == 2'b10) |-> (ARLEN inside {8'd1, 8'd3, 8'd7, 8'd15});
endproperty

assert property (arlen_for_wrap)
    else $error("AXI3: Invalid ARLEN=%0d for WRAP burst", ARLEN);

//=========================================
        // READ DATA CHANNEL (R):
//=========================================

// RLAST must occur with RVALID
        
property rlast_with_rvalid;
        @(posedge AClk) disable iff (!ARESETn) RLAST |-> RVALID;
endproperty

assert property (rlast_with_rvalid)
    else $error("AXI3: RLAST asserted without RVALID");

//=========================================
        // modports:
//=========================================
        
modport MDRV (clocking mstr_drv_cb);
modport MMON (clocking mstr_mon_cb);

modport SDRV (clocking slv_drv_cb);
modport SMON (clocking slv_mon_cb);

endinterface


