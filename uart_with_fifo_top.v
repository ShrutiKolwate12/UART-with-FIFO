module uart_with_fifo_top (
    input wire clk,
    input wire rst,
    input wire [7:0] tx_data,
    input wire tx_wr_en,
    input wire rx_rd_en,
    input wire rx,
    output wire tx,
    output wire [7:0] rx_data,
    output wire tx_fifo_full,
    output wire rx_fifo_empty
);

    uart_tx_fifo #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) TX (
        .clk(clk), .rst(rst),
        .wr_en(tx_wr_en), .data_in(tx_data),
        .tx(tx), .fifo_full(tx_fifo_full)
    );

    uart_rx_fifo #(.CLK_FREQ(50000000), .BAUD_RATE(9600)) RX (
        .clk(clk), .rst(rst), .rx(rx),
        .rd_en(rx_rd_en), .data_out(rx_data),
        .fifo_empty(rx_fifo_empty)
    );

endmodule
