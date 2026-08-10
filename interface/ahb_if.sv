interface ahb_if(input logic HCLK);

    //==================================================
    // AHB RESET
    //==================================================
    logic HRESETn;

    //==================================================
    // AHB MASTER -> DUT
    //==================================================
    logic        HSEL;
    logic        HWRITE;
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic [2:0]  HBURST;

    //==================================================
    // DUT -> AHB MASTER
    //==================================================
    logic [31:0] HRDATA;
    logic        HREADY;
    logic        HRESP;

endinterface
