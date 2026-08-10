module sram(

    input  logic        clk,
    input  logic        cs,
    input  logic        we,
    input  logic [7:0]  addr,
    input  logic [31:0] wdata,
    output logic [31:0] rdata

);

    logic [31:0] mem [0:255];

    // ==================================================
    // WRITE
    // ==================================================

    always_ff @(posedge clk) begin

        if (cs && we) begin

            mem[addr] <= wdata;

            $display(
                "[SRAM] WRITE: ADDR=%02h DATA=%08h",
                addr,
                wdata
            );

        end

    end

    // ==================================================
    // ASYNCHRONOUS READ
    // ==================================================

    always_comb begin

        rdata = mem[addr];

    end

    // ==================================================
    // DEBUG READ
    // ==================================================

    always @(posedge clk) begin

        if (cs && !we) begin

            $display(
                "[SRAM] READ : ADDR=%02h DATA=%08h",
                addr,
                mem[addr]
            );

        end

    end

endmodule
