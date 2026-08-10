interface Axi3_if(input bit AClk);

logic ARESETn;

//write address channel (AW):

logic [31:0] AWADDR;
logic [3:0] AWLEN;
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
logic [3:0] ARLEN;
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

// modports:

modport MDRV (clocking mstr_drv_cb);
modport MMON (clocking mstr_mon_cb);

modport SDRV (clocking slv_drv_cb);
modport SMON (clocking slv_mon_cb);

endinterface
