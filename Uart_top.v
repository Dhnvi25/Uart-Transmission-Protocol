module uart_top(
    input  wire       clk,
    input  wire       rst,

    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output wire       tx,
    output wire       tx_busy,
    output wire       tx_done,

    output wire [7:0] rx_data,
    output wire       rx_done
);

wire baud_tick;
wire oversample_tick;

// Internal loopback wire
wire serial_line;

baud_gen #(
    .CLK_FREQ(100_000_000),
    .BAUD_RATE(115200)
) u_baud_gen (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .oversample_tick(oversample_tick)
);

uart_tx u_uart_tx (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(serial_line),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

uart_rx u_uart_rx (
    .clk(clk),
    .rst(rst),
    .oversample_tick(oversample_tick),
    .rx(serial_line),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

assign tx = serial_line;

endmodule
