`timescale 1ns / 1ps

module tb_uart_top;

reg clk;
reg rst;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire tx_busy;
wire tx_done;
wire [7:0] rx_data;
wire rx_done;

// DUT
uart_top dut (
    .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy),
    .tx_done(tx_done),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

always #5 clk = ~clk;

// =====================================================
// Task: complete reset + send one byte
// =====================================================
task send_with_reset;
    input [7:0] data;
    begin
        // ---------- FULL RESET ----------
        rst      = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        #100;
        rst = 1'b0;

        // allow all counters and FSMs to stabilize
        #1000;

        // ---------- SEND BYTE ----------
        tx_data  = data;
        tx_start = 1'b1;

        #10;   // one clock cycle
        tx_start = 1'b0;

        // wait long enough for one complete UART frame
        // 10 bits × 8.68 us ≈ 86.8 us
        #120000;
    end
endtask

// =====================================================
// Test sequence
// =====================================================
initial begin
    clk = 1'b0;

    // ---------------- TEST 1 ----------------
    send_with_reset(8'h55);

    // ---------------- TEST 2 ----------------
    send_with_reset(8'hA3);

    // ---------------- TEST 3 ----------------
    send_with_reset(8'h3C);

    // extra observation time
    #50000;

    $finish;
end

endmodule
