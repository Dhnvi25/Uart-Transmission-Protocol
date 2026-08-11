module baud_gen
#(
    parameter CLK_FREQ  = 100000,
    parameter BAUD_RATE = 100
)
(
    input  wire clk,
    input  wire rst,
    output reg  baud_tick,
    output reg  oversample_tick
);

localparam integer BAUD_DIV = CLK_FREQ / BAUD_RATE;        // 868
localparam integer OVER_DIV = CLK_FREQ / (BAUD_RATE * 16); // 54

reg [15:0] baud_count;
reg [15:0] over_count;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        baud_count      <= 0;
        over_count      <= 0;
        baud_tick       <= 1'b0;
        oversample_tick <= 1'b0;
    end else begin
        // defaults
        baud_tick       <= 1'b0;
        oversample_tick <= 1'b0;

        // baud tick
        if (baud_count == BAUD_DIV - 1) begin
            baud_count <= 0;
            baud_tick  <= 1'b1;
        end else begin
            baud_count <= baud_count + 1'b1;
        end

        // 16x oversampling tick
        if (over_count == OVER_DIV - 1) begin
            over_count      <= 0;
            oversample_tick <= 1'b1;
        end else begin
            over_count <= over_count + 1'b1;
        end
    end
end

endmodule
