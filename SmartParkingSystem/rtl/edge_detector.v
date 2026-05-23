// Edge Detector Module
// Detects rising edge using flip-flop chain
// Author: Akshat Raj (24BCE0043)

module edge_detector (
    input wire clk,
    input wire reset,
    input wire signal_in,
    output reg pulse_out
);

    // D flip-flop to store previous state
    reg signal_delayed;

    // Sequential logic - two D flip-flops
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            signal_delayed <= 1'b0;
            pulse_out <= 1'b0;
        end
        else begin
            signal_delayed <= signal_in;
            // Rising edge detection: current high AND previous low
            pulse_out <= signal_in & ~signal_delayed;
        end
    end

endmodule