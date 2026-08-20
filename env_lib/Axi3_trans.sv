 `include "uvm_macros.svh"
  import uvm_pkg::*;

class Axi3_trans extends uvm_sequence_item;

bit RESETn;  // global signal

// ============================================================
            // WRITE ADDRESS CHANNEL (AW)
// ============================================================

rand bit [3:0]  AWID;
rand bit [31:0] AWADDR;
rand bit [7:0]  AWLEN;
rand bit [2:0]  AWSIZE;
rand bit [1:0]  AWBURST;
rand bit [1:0]  AWLOCK;
rand bit [3:0]  AWCACHE;
rand bit [2:0]  AWPROT;
logic AWREADY; //signal driven by slave to handle (X/Z)
bit AWVALID; //handshake signal indicates address control is present

// ============================================================
               // WRITE DATA CHANNEL (W)
// ============================================================

rand bit [31:0] WDATA[];
rand bit [3:0]  WID;
bit [3:0]  WSTRB[]; // WSTRB is generated from address and transfer size
bit  WLAST;
bit  WVALID;
logic WREADY;

// ============================================================
              // WRITE RESPONSE CHANNEL (B)
// ============================================================

rand bit [3:0] BID;
logic [1:0] BRESP;
logic BVALID;
bit BREADY;

// ============================================================
             // READ ADDRESS CHANNEL (AR)
// ============================================================

rand bit [3:0] ARID;
rand bit [31:0] ARADDR;
rand bit [7:0] ARLEN;
rand bit [2:0] ARSIZE;
rand bit [1:0] ARBURST;

logic ARREADY;
bit ARVALID;

// ============================================================
              // READ DATA CHANNEL (R)
// ============================================================
rand bit [3:0] RID;
rand logic [31:0] RDATA[];
logic [1:0] RRESP[];
logic RLAST;

bit RREADY;
logic RVALID;

 //factory registration
 //        `uvm_object_utils(Axi3_trans)
           `uvm_object_utils_begin(Axi3_trans)

               // Write Address Channel
               `uvm_field_int(AWID,    UVM_ALL_ON)
               `uvm_field_int(AWADDR,  UVM_ALL_ON)
               `uvm_field_int(AWLEN,   UVM_ALL_ON)
               `uvm_field_int(AWSIZE,  UVM_ALL_ON)
               `uvm_field_int(AWBURST, UVM_ALL_ON)

               // Write Data Channel
               `uvm_field_int(WID,     UVM_ALL_ON)
               `uvm_field_array_int(WDATA, UVM_ALL_ON)
               `uvm_field_array_int(WSTRB, UVM_ALL_ON)
               `uvm_field_int(WLAST,   UVM_ALL_ON)
           
               // Write Response Channel
               `uvm_field_int(BID,     UVM_ALL_ON)
               `uvm_field_int(BRESP,   UVM_ALL_ON)
           
               // Read Address Channel
               `uvm_field_int(ARID,    UVM_ALL_ON)
               `uvm_field_int(ARADDR,  UVM_ALL_ON)
               `uvm_field_int(ARLEN,   UVM_ALL_ON)
               `uvm_field_int(ARSIZE,  UVM_ALL_ON)
               `uvm_field_int(ARBURST, UVM_ALL_ON)
           
               // Read Data Channel
               `uvm_field_int(RID,     UVM_ALL_ON)
               `uvm_field_array_int(RDATA, UVM_ALL_ON)
               `uvm_field_array_int(RRESP, UVM_ALL_ON)
               `uvm_field_int(RLAST,   UVM_ALL_ON)
           
          `uvm_object_utils_end

bit [31:0] waddr[];
int no_of_wbytes;
int start_waddr;
int aligned_waddr;


bit [31:0] raddr[];
int no_of_rbytes;
int start_raddr;
int aligned_raddr;

//write/read data size constraint:

constraint wdata_c1 { WDATA.size() == (AWLEN+1); } //burst len = AWLEN+1

constraint rdata_c2 { RDATA.size() == (ARLEN+1); }

//write/read burst type distribution:

constraint awb {AWBURST dist{ 2'b00 :=10, 2'b01 :=10, 2'b10 :=10};}

constraint arb {ARBURST dist{ 2'b00 :=10, 2'b01 :=10, 2'b10 :=10};}

//ID constraint::

constraint write_id { WID == AWID; BID == WID; } //awid -> wid -> bid

constraint read_id { RID == ARID; }

//transfer size distribution:

constraint awsize { AWSIZE dist { 0:=10, 1:=10, 2:=10}; }

constraint arsize { ARSIZE dist { 0:=10, 1:=10, 2:=10}; }

//wrap burst length constraint:
constraint awlen_c {
    if(AWBURST == 2'b10)
        (AWLEN + 1) inside {2,4,8,16};}

constraint arlen_c{
    if(ARBURST == 2'b10)
        (ARLEN + 1) inside {2,4,8,16};}

//address alignment constraint:

constraint write_alignment_c1 { ((AWBURST == 2'b10 || AWBURST == 2'b00) &&  AWSIZE == 1) -> (AWADDR % 2 == 0);}
constraint write_alignment_c2 { ((AWBURST == 2'b10 || AWBURST == 2'b00) &&  AWSIZE == 2) -> (AWADDR % 4 == 0);}


constraint read_alignment_c1 { ((ARBURST == 2'b10 || ARBURST == 2'b00) &&  ARSIZE == 1) -> (ARADDR % 2 == 0);}
constraint read_alignment_c2 { ((ARBURST == 2'b10 || ARBURST == 2'b00) &&  ARSIZE == 2) -> (ARADDR % 4 == 0);}

//general burst length:

constraint awlen_default_c{ AWLEN inside {[0:15]}; }
constraint arlen_default_c{ ARLEN inside {[0:15]}; }

//boundary constraints:  4kb

constraint c1 {awaddr < 4096;}
constraint c2 {araddr < 4096;}

extern function new(string name = "Axi3_trans");
extern function void post_randomize();
//extern function void do_print(uvm_printer printer);
//extern function bit do_compare(uvm_object rhs, uvm_comparer comparer);

extern function void cal_addr();
extern function void cal_raddr();
extern function void strb_cal();

endclass: Axi3_trans

function Axi3_trans::new(string name = "Axi3_trans");
        super.new(name);
endfunction: new

function void Axi3_trans::post_randomize();

        no_of_wbytes = 2**AWSIZE; //no of bytes transfer in one beat
        aligned_waddr = (int'(AWADDR/no_of_wbytes))*no_of_wbytes;
        start_waddr = AWADDR;//store the orginal wr address
        WSTRB = new[AWLEN+1];//array

        no_of_rbytes = 2**ARSIZE;
        aligned_raddr = (int'(ARADDR/no_of_rbytes))*no_of_rbytes;
        start_raddr = ARADDR;

        cal_addr();
        strb_cal();
        cal_raddr();
 
foreach (waddr[i]) begin
    `uvm_info(get_type_name(),
        $sformatf("Beat=%0d Address=0x%0h", i, waddr[i]),
        UVM_LOW)
end
 
endfunction: post_randomize

function void Axi3_trans::cal_addr();

    bit wb = 0; // Is wrap happened?

    int burst_len = AWLEN + 1;
    int wrap_boundary = (int'(AWADDR / (no_of_wbytes * burst_len))) *  (no_of_wbytes * burst_len);
              ///wb = (start address /burst size ) * burst size
    int addr_n = wrap_boundary + (no_of_wbytes * burst_len);

    waddr = new[AWLEN + 1];
    waddr[0] = AWADDR;

    for (int i = 2; i < (burst_len + 1); i++)
    begin

        // FIXED Burst
        if (AWBURST == 0)
        begin
            waddr[i-1] = AWADDR;
        end

        // INCR Burst
        else if (AWBURST == 1)
        begin
            waddr[i-1] = aligned_waddr + ((i-1) * no_of_wbytes);
        end

        // WRAP Burst
        else if (AWBURST == 2)
        begin
            if (wb == 0)
            begin
                waddr[i-1] = aligned_waddr + ((i-1) * no_of_wbytes);

                if (waddr[i-1] == addr_n)
                begin
                    waddr[i-1] = wrap_boundary;
                    wb++;
                end
            end
            else
            begin
                waddr[i-1] = start_waddr +
                             ((i-1) * no_of_wbytes) -
                             (no_of_wbytes * burst_len);
            end
        end

    end

endfunction: cal_addr

function void Axi3_trans::strb_cal();

    int data_bus_bytes = 4;
    int lower_byte_lane, upper_byte_lane;

    int lower_byte_lane_0 = start_waddr - ((int'(start_waddr/data_bus_bytes)) * data_bus_bytes);
    int upper_byte_lane_0 = (aligned_waddr + (no_of_wbytes - 1)) - ((int'(start_waddr/data_bus_bytes)) * data_bus_bytes);

    for (int j = lower_byte_lane_0; j <= upper_byte_lane_0; j++)
    begin
        WSTRB[0][j] = 1;
    end

    for (int i = 1; i < (AWLEN + 1); i++)
    begin
        lower_byte_lane = waddr[i] -
                          ((int'(waddr[i]/data_bus_bytes)) * data_bus_bytes);

        upper_byte_lane = lower_byte_lane + no_of_wbytes - 1;

        for (int j = lower_byte_lane; j <= upper_byte_lane; j++)
            WSTRB[i][j] = 1;
    end

endfunction: strb_cal

function void Axi3_trans::cal_raddr();

    bit wb = 0;
    int burst_len = ARLEN + 1;
    int wrap_boundary = (int'(ARADDR / (no_of_rbytes * burst_len))) * (no_of_rbytes * burst_len);
    int raddr_n = wrap_boundary + (no_of_rbytes * burst_len);

    raddr = new[ARLEN + 1];
    raddr[0] = ARADDR;

    for (int i = 2; i < (burst_len + 1); i++)
    begin

        // FIXED Burst
        if (ARBURST == 0)
            raddr[i-1] = ARADDR;

        // INCR Burst
        else if (ARBURST == 1)
        begin
            raddr[i-1] = aligned_raddr + (i - 1) * no_of_rbytes;
        end

        // WRAP Burst
        else if (ARBURST == 2)
        begin
            if (wb == 0)
            begin
                raddr[i-1] = aligned_raddr + (i - 1) * no_of_rbytes;

                if (raddr[i-1] == raddr_n)
                begin
                    raddr[i-1] = wrap_boundary;
                    wb++;
                end
            end
            else
            begin
                raddr[i-1] = start_raddr +
                             ((i - 1) * no_of_rbytes) -
                             (no_of_rbytes * burst_len);
            end
        end

    end

endfunction: cal_raddr

/*
function void Axi3_trans::do_print(uvm_printer printer);

    super.do_print(printer);

    // Write Address Channel
    //               field name  bitstream value  size  radix for printing

    printer.print_field("AWID",    this.AWID,     4, UVM_DEC);
    printer.print_field("AWADDR",  this.AWADDR,  32, UVM_HEX);
    printer.print_field("AWLEN",   this.AWLEN,    4, UVM_DEC);
    printer.print_field("AWSIZE",  this.AWSIZE,   3, UVM_DEC);
    printer.print_field("AWBURST", this.AWBURST,  2, UVM_DEC);


    // Write Data Channel
    //          field name    bitstream value    size    radix for printing

    printer.print_field("WID", this.WID, 4, UVM_DEC);

    foreach (this.WDATA[i])
    begin
        printer.print_field("WDATA", this.WDATA[i], 32, UVM_HEX);
        printer.print_field("WSTRB", this.WSTRB[i],  4, UVM_BIN);
        printer.print_field("WLAST", this.WLAST,     1, UVM_DEC);
    end


    // Write Response Channel
    //          field name    bitstream value    size    radix for printing

    printer.print_field("BID",   this.BID,   4, UVM_DEC);
    printer.print_field("BRESP", this.BRESP, 2, UVM_DEC);


    // Read Address Channel
    //           field name    bitstream value    size    radix for printing

    printer.print_field("ARID",    this.ARID,     4, UVM_DEC);
    printer.print_field("ARADDR",  this.ARADDR,  32, UVM_HEX);
    printer.print_field("ARLEN",   this.ARLEN,    4, UVM_DEC);
    printer.print_field("ARSIZE",  this.ARSIZE,   3, UVM_DEC);
    printer.print_field("ARBURST", this.ARBURST,  2, UVM_DEC);


    // Read Data Channel
    //            field name    bitstream value    size    radix for printing

    printer.print_field("RID", this.RID, 4, UVM_DEC);

    foreach (this.RDATA[i])
    begin
        printer.print_field("RDATA", this.RDATA[i], 32, UVM_HEX);
        printer.print_field("RRESP", this.RRESP[i],  2, UVM_DEC);
    end

endfunction: do_print

function bit Axi3_trans::do_compare(uvm_object rhs, uvm_comparer comparer);

    Axi3_trans rhs_;

    if(!$cast(rhs_, rhs))
    begin
        `uvm_fatal("DO_COMPARE", "Cast failed")
        return 0;
    end

    return super.do_compare(rhs, comparer) &&

           // Write Address Channel
           AWID    == rhs_.AWID    &&
           AWADDR  == rhs_.AWADDR  &&
           AWLEN   == rhs_.AWLEN   &&
           AWSIZE  == rhs_.AWSIZE  &&
           AWBURST == rhs_.AWBURST &&

           // Write Data Channel
           WID     == rhs_.WID     &&
           WDATA   == rhs_.WDATA   &&
           WSTRB   == rhs_.WSTRB   &&

           // Write Response Channel
           BID     == rhs_.BID     &&
           BRESP   == rhs_.BRESP   &&

           // Read Address Channel
           ARID    == rhs_.ARID    &&
           ARADDR  == rhs_.ARADDR  &&
           ARLEN   == rhs_.ARLEN   &&
           ARSIZE  == rhs_.ARSIZE  &&
           ARBURST == rhs_.ARBURST &&

           // Read Data Channel
           RID     == rhs_.RID     &&
           RDATA   == rhs_.RDATA   &&
           RRESP   == rhs_.RRESP;

endfunction: do_compare
*/
//To check:
/*module tb();

        Axi3_trans xtn;

        initial begin
                xtn = Axi3_trans::type_id::create("xtn");
                xtn.randomize();

                `uvm_info("TB", $sformatf("transaction details \n %s",xtn.sprint()),UVM_LOW);
        end
endmodule*/

                                                                                                          
