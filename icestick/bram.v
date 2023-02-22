
module bram #(
    parameter DW = 8,
    parameter AW = 9
) (
    input                   clk,
    input                   rd,
    input       [AW-1:0]    raddr,
    input                   wr,
    input       [AW-1:0]    waddr,
    input       [DW-1:0]    din,
    output reg  [DW-1:0]    dout
);

    reg [DW-1:0] ram [2**AW-1:0];

    always @(posedge clk) begin
        if (rd)
            dout <= ram[raddr];
        if (wr)
            ram[waddr] <= din;
    end

endmodule
