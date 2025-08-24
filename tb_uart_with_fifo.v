`timescale 1ns/1ps

module tb_uart_with_fifo;

    // Clock and reset
    reg clk = 0;
    reg rst = 1;

    // TX side
    reg [7:0] tx_data;
    reg tx_wr_en;
    wire tx;
    wire tx_fifo_full;

    // RX side
    reg rx_rd_en;
    wire [7:0] rx_data;
    wire rx_fifo_empty;

    // Loopback RX to TX
    wire rx = tx;

    // DUT instance
    uart_with_fifo_top uut (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_wr_en(tx_wr_en),
        .rx_rd_en(rx_rd_en),
        .rx(rx),
        .tx(tx),
        .rx_data(rx_data),
        .tx_fifo_full(tx_fifo_full),
        .rx_fifo_empty(rx_fifo_empty)
    );

    // Clock generation (50 MHz)
    always #10 clk = ~clk; // 20ns period

    initial begin
        $dumpfile("uart_with_fifo_tb.vcd");
        $dumpvars(0, tb_uart_with_fifo);

        // Reset
        rst = 1;
        tx_wr_en = 0;
        rx_rd_en = 0;
        #100;
        rst = 0;

        // Write multiple bytes quickly into TX FIFO
        send_byte(8'h41); // 'A'
        send_byte(8'h42); // 'B'
        send_byte(8'h43); // 'C'
        send_byte(8'h44); // 'D'

        // Wait for UART to transmit all data
        #200000;

        // Read received bytes from RX FIFO
        read_byte();
        read_byte();
        read_byte();
        read_byte();

        #1000;
        $finish;
    end

    // Task to send byte into TX FIFO
    task send_byte(input [7:0] data);
    begin
        @(posedge clk);
        tx_data = data;
        tx_wr_en = 1;
        @(posedge clk);
        tx_wr_en = 0;
    end
    endtask

    // Task to read byte from RX FIFO
    task read_byte;
    begin
        @(posedge clk);
        rx_rd_en = 1;
        @(posedge clk);
        $display("RX Data: %c (%h)", rx_data, rx_data);
        rx_rd_en = 0;
    end
    endtask

endmodule
