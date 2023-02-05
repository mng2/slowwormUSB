


module top (
    // icestick
    input   CLK,
    output  LED_UP, LED_DOWN, LED_LEFT, LED_RIGHT,
    output  LED_MIDDLE,
    output  TXD,
    input   RXD,
    input   RESETQ,
    // slowworm PMOD
    output  ACTIVITY,
    output  USB_OE,
    input   USB_DP, USB_DM
);

    wire uart_valid;
    wire [7:0] rx_data;
    reg  [7:0] tx_data;
    reg  uart_wr;
    wire uart_busy;

    buart _uart (
        .clk(CLK),
        .resetq(1'b1),
        .rx(RXD),
        .tx(TXD),
        .rd(1'b1),
        .wr(uart_wr),
        .valid(uart_valid),
        .busy(uart_busy),
        .tx_data(tx_data),
        .rx_data(rx_data)
    );
/*
    always @(posedge CLK) begin
        if(uart_valid) begin
            tx_data    <= rx_data;
            uart_wr    <= 1'b1;
        end else begin
            uart_wr    <= 1'b0;
        end
    end
*/

    reg [23:0] alive_counter;
    always @(posedge CLK) begin
        if (uart_valid)
            alive_counter <= 24'hFFFFFF;
        else if (alive_counter)
            alive_counter = alive_counter - 1;
    end

    assign LED_MIDDLE = |alive_counter;
    assign ACTIVITY = tx_data[0];

    localparam USB_DRIVE_EN = 1'b1;
    localparam USB_HI_Z = 1'b0;
    assign USB_OE = USB_HI_Z;

    always @(posedge CLK) begin
        LED_UP <= USB_DP;
        LED_DOWN <= USB_DM;
        uart_wr <= 1'b0;
        if (~uart_busy) begin
            if (USB_DP) begin
                tx_data <= 8'd112; // "p"
                uart_wr <= 1'b1;
            end else if (USB_DM) begin
                tx_data <= 8'd109; // "m"
                uart_wr <= 1'b1;
            end
        end
    end

endmodule
