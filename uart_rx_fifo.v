module uart_rx_fifo #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire rst,
    input wire rx,
    input wire rd_en,
    output wire [7:0] data_out,
    output wire fifo_empty
);

    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;
    localparam HALF_BAUD = BAUD_TICK / 2;

    reg [15:0] baud_cnt = 0;
    reg [3:0] bit_idx = 0;
    reg [7:0] rx_data = 0;
    reg rx_busy = 0;

    reg fifo_wr_en = 0;

    fifo #(8, 16) rx_fifo (
        .clk(clk), .rst(rst), .wr_en(fifo_wr_en), .rd_en(rd_en),
        .din(rx_data), .dout(data_out), .full(), .empty(fifo_empty)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_idx <= 0;
            rx_busy <= 0;
            fifo_wr_en <= 0;
        end else begin
            fifo_wr_en <= 0;

            if (!rx_busy && !rx) begin
                rx_busy <= 1;
                baud_cnt <= 0;
                bit_idx <= 0;
            end else if (rx_busy) begin
                baud_cnt <= baud_cnt + 1;
                if (bit_idx == 0 && baud_cnt == HALF_BAUD) begin
                    baud_cnt <= 0;
                    bit_idx <= 1;
                end else if (baud_cnt == BAUD_TICK) begin
                    baud_cnt <= 0;
                    if (bit_idx >= 1 && bit_idx <= 8)
                        rx_data[bit_idx-1] <= rx;
                    else if (bit_idx == 9) begin
                        fifo_wr_en <= 1;
                        rx_busy <= 0;
                    end
                    bit_idx <= bit_idx + 1;
                end
            end
        end
    end
endmodule
