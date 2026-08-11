module uart_tx(
    input  wire       clk,
    input  wire       rst,
    input  wire       baud_tick,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx,
    output reg        tx_busy,
    output reg        tx_done
);

localparam IDLE  = 2'd0;
localparam START = 2'd1;
localparam DATA  = 2'd2;
localparam STOP  = 2'd3;

reg [1:0] state;
reg [7:0] data_reg;
reg [2:0] bit_index;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state     <= IDLE;
        tx        <= 1'b1;
        tx_busy   <= 1'b0;
        tx_done   <= 1'b0;
        data_reg  <= 8'd0;
        bit_index <= 3'd0;
    end else begin
        tx_done <= 1'b0;

        case (state)

            IDLE: begin
                tx      <= 1'b1;
                tx_busy <= 1'b0;

                if (tx_start) begin
                    data_reg  <= tx_data;
                    bit_index <= 3'd0;
                    tx_busy   <= 1'b1;
                    state     <= START;
                end
            end

            START: begin
                tx <= 1'b0;

                if (baud_tick)
                    state <= DATA;
            end

            DATA: begin
                tx <= data_reg[bit_index];

                if (baud_tick) begin
                    if (bit_index == 3'd7)
                        state <= STOP;
                    else
                        bit_index <= bit_index + 1'b1;
                end
            end

            STOP: begin
                tx <= 1'b1;

                if (baud_tick) begin
                    tx_done <= 1'b1;
                    tx_busy <= 1'b0;
                    state   <= IDLE;
                end
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule
