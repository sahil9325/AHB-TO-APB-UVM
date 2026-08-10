module ahb_apb_bridge(
    input  logic        HCLK,
    input  logic        HRESETn,

    // AHB
    input  logic        HSEL,
    input  logic [31:0] HADDR,
    input  logic        HWRITE,
    input  logic [31:0] HWDATA,
    input  logic [2:0]  HBURST,

    output logic [31:0] HRDATA,
    output logic        HREADY,
    output logic        HRESP,

    // APB
    output logic        PSEL,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    input  logic [31:0] PRDATA,
    input  logic        PREADY,
    input  logic        PSLVERR
);

    typedef enum logic [1:0] {
        IDLE,
        SETUP,
        ACCESS
    } state_t;

    state_t current_state, next_state;

    logic [31:0] addr_reg;
    logic [31:0] wdata_reg;
    logic        write_reg;
    logic [2:0]  burst_reg;


    // =========================================================
    // STATE REGISTER
    // =========================================================

    always_ff @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn)
            current_state <= IDLE;

        else
            current_state <= next_state;

    end


    // =========================================================
    // CAPTURE AHB REQUEST
    // =========================================================

    always_ff @(posedge HCLK or negedge HRESETn) begin

        if (!HRESETn) begin

            addr_reg  <= 32'h00000000;
            wdata_reg <= 32'h00000000;
            write_reg <= 1'b0;
            burst_reg <= 3'b000;

        end

        else if ((current_state == IDLE) && HSEL) begin

            addr_reg  <= HADDR;
            wdata_reg <= HWDATA;
            write_reg <= HWRITE;
            burst_reg <= HBURST;

        end

    end


    // =========================================================
    // NEXT STATE LOGIC
    // =========================================================

    always_comb begin

        next_state = current_state;

        case (current_state)

            IDLE: begin

                if (HSEL)
                    next_state = SETUP;

            end


            SETUP: begin

                next_state = ACCESS;

            end


            ACCESS: begin

                if (PREADY)
                    next_state = IDLE;

            end


            default: begin

                next_state = IDLE;

            end

        endcase

    end


    // =========================================================
    // APB OUTPUTS
    // =========================================================

    always_comb begin

        PSEL    = 1'b0;
        PENABLE = 1'b0;
        PWRITE  = write_reg;
        PADDR   = addr_reg;
        PWDATA  = wdata_reg;

        case (current_state)

            SETUP: begin

                PSEL    = 1'b1;
                PENABLE = 1'b0;

            end


            ACCESS: begin

                PSEL    = 1'b1;
                PENABLE = 1'b1;

            end


            default: begin

                PSEL    = 1'b0;
                PENABLE = 1'b0;

            end

        endcase

    end


    // =========================================================
    // AHB RESPONSE
    // =========================================================

    always_comb begin

        HREADY = 1'b0;
        HRESP  = 1'b0;
        HRDATA = 32'h00000000;

        case (current_state)

            IDLE: begin

                HREADY = 1'b1;
                HRESP  = 1'b0;

            end


            SETUP: begin

                HREADY = 1'b0;
                HRESP  = 1'b0;

            end


            ACCESS: begin

                HREADY = PREADY;

                // Propagate APB error to AHB.
                //
                // HRESP is meaningful when the APB
                // transfer completes.

                if (PREADY)
                    HRESP = PSLVERR;

                else
                    HRESP = 1'b0;


                // Return APB read data to AHB.

                if (!write_reg)
                    HRDATA = PRDATA;

            end


            default: begin

                HREADY = 1'b1;
                HRESP  = 1'b0;

            end

        endcase

    end

endmodule
