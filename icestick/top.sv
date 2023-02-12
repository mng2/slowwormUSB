
module top (
    // icestick
    input   CLK,
    output logic LED_UP, LED_DOWN, 
    output  LED_LEFT, LED_RIGHT,
    output  LED_MIDDLE,
    output  TXD,
    input   RXD,
    input   RESETQ,
    // slowworm PMOD
    output  ACTIVITY,
    output  USB_OE,
    input   USB_DP, USB_DM,
    output  USB_OUT_DP, USB_OUT_DM
);

    logic uart_valid;
    logic [7:0] rx_data;
    logic [7:0] string_char;
    logic uart_wr;
    logic uart_busy;

    buart _uart (
        .clk(CLK),
        .resetq(1'b1),
        .rx(RXD),
        .tx(TXD),
        .rd(1'b1),
        .wr(uart_wr),
        .valid(uart_valid),
        .busy(uart_busy),
        .tx_data(string_char),
        .rx_data(rx_data)
    );

    logic [8:0] string_addr;

    strings strings_inst(
        .clk(CLK),
        .rd('1),
        .raddr(string_addr),
        .dout(string_char),
        .wr('0), .waddr('0), .din('0)
    );

    // Orchestrate string "printing" via UART.
    // There is a "gap" to be minded due to the BRAM latency.
    logic string_busy = '0;
    logic string_startup_gap = '0;
    logic string_add_newline = '0;
    always_ff @(posedge CLK) begin
        uart_wr <= '0;
        string_startup_gap <= '0;
        if (~string_busy) begin
            if (uart_valid) begin
                string_busy <= '1;
                string_startup_gap <= '1;
                string_add_newline <= '1;
                if (rx_data < 65) begin
                    string_addr <= pkg_strings::S_hello_world;
                end else begin
                    string_addr <= pkg_strings::S_startup_message;
                end
            end
        end else if (string_busy) begin
            if (string_char != 0) begin
                if (~uart_busy & ~uart_wr) begin
                    uart_wr <= '1;
                    string_addr <= string_addr + 1;
                end
            end else begin // if null char
                if (~string_startup_gap) begin
                    if (string_add_newline) begin
                        string_addr <= pkg_strings::S_CRLF;
                        string_add_newline <= '0;
                        string_startup_gap <= '1;
                    end else
                        string_busy <= '0;
                end
            end
        end
    end

    logic [23:0] alive_counter;
    always_ff @(posedge CLK) begin
        if (uart_valid)
            alive_counter <= 24'hFFFFFF;
        else if (alive_counter)
            alive_counter = alive_counter - 1;
    end

    assign LED_MIDDLE = |alive_counter;
    assign LED_RIGHT = 1'b0;
    assign LED_LEFT = 1'b0;
    assign ACTIVITY = string_char[0];

    localparam USB_DRIVE_EN = 1'b1;
    localparam USB_HI_Z = 1'b0;
    assign USB_OE = USB_HI_Z;

    always_ff @(posedge CLK) begin
        LED_UP <= USB_DP;
        LED_DOWN <= USB_DM;
    end

endmodule
