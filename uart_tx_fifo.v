module uart_tx_fifo #(
    parameter CLK_FREQ = 50000000,  // 50 MHz clock
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire [7:0] data_in,
    output wire tx,
    output wire fifo_full
);

    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

    wire fifo_empty;
    reg rd_en = 0;
    reg [15:0] baud_cnt = 0;
    reg [3:0] bit_idx = 0;
    reg [9:0] tx_shift = 10'b1111111111;
    reg tx_busy = 0;
    wire [7:0] fifo_out;

    fifo #(8, 16) tx_fifo (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .din(data_in), .dout(fifo_out), .full(fifo_full), .empty(fifo_empty)
    );

    assign tx = tx_shift[0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            baud_cnt <= 0;
            bit_idx <= 0;
            tx_busy <= 0;
            tx_shift <= 10'b1111111111;
            rd_en <= 0;
        end else begin
            if (!tx_busy && !fifo_empty) begin
                rd_en <= 1;
                tx_shift <= {1'b1, fifo_out, 1'b0}; // stop bit, data, start bit
                tx_busy <= 1;
                bit_idx <= 0;
                baud_cnt <= 0;
            end else begin
                rd_en <= 0;
            end

            if (tx_busy) begin
                if (baud_cnt == BAUD_TICK-1) begin
                    baud_cnt <= 0;
                    tx_shift <= {1'b1, tx_shift[9:1]};
                    bit_idx <= bit_idx + 1;
                    if (bit_idx == 9) tx_busy <= 0;
                end else begin
                    baud_cnt <= baud_cnt + 1;
                end
            end
        end
    end
endmodule
