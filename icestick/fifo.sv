
// simple FIFO, same clock for rd/wr
// use chasing pointer scheme, extra bit to signify going "beyond"
// limitations: cannot rd+wr when full

module fifo #(
    parameter DW = 8,
    parameter AW = 9
)(
    input   clk, rst,
    input   wr,
    input   [DW-1:0] din,
    input   rd,
    output  [DW-1:0] dout,
    output logic valid,
    output logic full, empty
);

    logic [AW:0] readpointer, writepointer;
    logic wrbram, rdbram;

    bram my_bram(
        .clk,
        .rd(rdbram),
        .raddr(readpointer[AW-1:0]), // verilog resizes these but just to be clear!
        .wr(wrbram),
        .waddr(writepointer[AW-1:0]),
        .din,
        .dout
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            readpointer     <= '0;
            writepointer    <= '0;
            valid           <= '0;
        end
        else begin
            if (wr && ~full) begin
                writepointer <= writepointer + 1;
            end
            valid <= '0;
            if (rd && ~empty) begin
                readpointer <= readpointer + 1;
                valid <= '1;
            end
        end
    end

    always_comb begin
        full = '0;
        empty = '0;
        if (readpointer[AW-1:0] == writepointer[AW-1:0]) begin
            if (readpointer[AW] == writepointer[AW]) begin
                empty = '1; //pointers matched exactly
            end else begin
                full = '1; //pointers matched "out of phase"
            end
        end

        if (wr && ~full)
            wrbram = '1;
        else
            wrbram = '0;
        if (rd && ~empty)
            rdbram = '1;
        else
            rdbram = '0;
    end

endmodule
