`timescale 1ns / 1ps

module tb_fifo();

    logic clk = '0;
    always #2 clk <= ~clk;
    logic rst = '1;

    logic wr, rd;
    logic [7:0] din, dout;
    logic valid, full, empty;

    fifo dutfifo(
        .clk, .rst,
        .wr,
        .din,
        .rd,
        .dout,
        .valid,
        .full, .empty
    );

    task stuff(input int count);
    begin
        @(posedge clk);
        wr <= '1;
        for(int ii = 0; ii < count; ii = ii + 1) begin
            din <= din + 1;
            @(posedge clk);
        end
        wr <= '0;
    end
    endtask

    task pull(input int count);
    begin
        @(posedge clk);
        rd <= '1;
        for (int ii = 0; ii < count; ii = ii + 1)
            @(posedge clk);
        rd <= '0;
    end
    endtask

    task both(input int count);
    begin
        @(posedge clk);
        rd <= '1;
        wr <= '1;
        for (int ii = 0; ii < count; ii = ii + 1) begin
            din <= din + 1;
            @(posedge clk);
        end
        rd <= '0;
        wr <= '0;
    end
    endtask

    initial begin
        wr = '0;
        rd = '0;
        din = '0;
        #100;
        rst <= '0;
        @(posedge clk);
        #20;
        @(posedge clk);
        stuff(2);
        stuff(10);
        pull(2);
        pull(10);
        
        stuff(512);
        pull(200);
        both(100);
        pull(312);

        stuff(512);
        pull(200);
        both(100);
        pull(312);
    end

endmodule