module apb_sram_ctrl(

    input  logic        PCLK,
    input  logic        PRESETn,

    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,

    output logic [31:0] PRDATA,
    output logic        PREADY
);

    logic [31:0] mem [0:255];

    // --------------------------------------------------
    // APB response
    //
    // This SRAM is a zero-wait-state APB peripheral.
    // --------------------------------------------------

    always_comb begin

        PREADY = 1'b0;
        PRDATA = 32'h00000000;

        if (PSEL && PENABLE) begin

            PREADY = 1'b1;

            if (!PWRITE)
                PRDATA = mem[PADDR[7:0]];

        end

    end


    // --------------------------------------------------
    // SRAM WRITE
    //
    // Perform the write directly when APB ACCESS is
    // active.
    // --------------------------------------------------

    always_ff @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin

            // Nothing required for SRAM initialization.

        end
        else if (PSEL && PENABLE && PWRITE) begin

            mem[PADDR[7:0]] <= PWDATA;

            $display(
                "[SRAM] WRITE: ADDR=%02h DATA=%08h",
                PADDR[7:0],
                PWDATA
            );

        end

    end


    // --------------------------------------------------
    // DEBUG
    // --------------------------------------------------

    always @(posedge PCLK) begin

        if (PSEL && PENABLE) begin

            if (PWRITE) begin

                $display(
                    "[APB_CTRL] WRITE: ADDR=%08h DATA=%08h",
                    PADDR,
                    PWDATA
                );

            end
            else begin

                $display(
                    "[APB_CTRL] READ : ADDR=%08h DATA=%08h",
                    PADDR,
                    mem[PADDR[7:0]]
                );

            end

        end

    end

endmodule
