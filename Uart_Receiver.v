module uart_rx(
    input  wire       clk,
    input  wire       rst,
    input  wire       oversample_tick,
    input  wire       rx,
    output reg  [7:0] rx_data,
    output reg        rx_done
);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;

// Synchronizer
reg rx_sync1, rx_sync2;

// Sampling control
reg [3:0] sample_count;
reg [2:0] bit_index;
reg [7:0] data_reg;

// Synchronize asynchronous RX input
always @(posedge clk or posedge rst) begin
    if (rst) begin
        rx_sync1 <= 1'b1;
        rx_sync2 <= 1'b1;
    end else begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state        <= IDLE;
        sample_count <= 4'd0;
        bit_index    <= 3'd0;
        data_reg     <= 8'd0;
        rx_data      <= 8'd0;
        rx_done      <= 1'b0;
    end else begin
        rx_done <= 1'b0;

        case (state)

            // -------------------------------------------------
            IDLE: begin
                sample_count <= 4'd0;
                bit_index    <= 3'd0;

                // detect falling edge (start bit)
                if (rx_sync2 == 1'b0) begin
                    state <= START;
                end
            end

            // -------------------------------------------------
            START: begin
                if (oversample_tick) begin
                    // wait 8 ticks to reach middle of start bit
                    if (sample_count == 4'd7) begin
                        sample_count <= 4'd0;

                        // confirm still low
                        if (rx_sync2 == 1'b0) begin
                            state <= DATA;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        sample_count <= sample_count + 1'b1;
                    end
                end
            end

            // -------------------------------------------------
            DATA: begin
                if (oversample_tick) begin
                    // sample every 16 ticks
                    if (sample_count == 4'd15) begin
                        sample_count <= 4'd0;

                        data_reg[bit_index] <= rx_sync2;

                        if (bit_index == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end else begin
                        sample_count <= sample_count + 1'b1;
                    end
                end
            end

            // -------------------------------------------------
            STOP: begin
                if (oversample_tick) begin
                    if (sample_count == 4'd15) begin
                        sample_count <= 4'd0;

                        // valid stop bit must be high
                        if (rx_sync2 == 1'b1) begin
                            rx_data <= data_reg;
                            rx_done <= 1'b1;
                        end

                        state <= IDLE;
                    end else begin
                        sample_count <= sample_count + 1'b1;
                    end
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
