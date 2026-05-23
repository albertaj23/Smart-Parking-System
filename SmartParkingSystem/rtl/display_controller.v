// 7-Segment Display Controller
// Converts 4-bit value to 7-segment display format
// Author: Akshat Raj (24BCE0043)

module display_controller (
    input wire clk,
    input wire reset,
    input wire [3:0] value,
    output reg [6:0] seven_seg
);

    // 7-segment encoding: {g,f,e,d,c,b,a}
    // Active low display
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seven_seg <= 7'b1111111;  // All segments off
        end
        else begin
            case (value)
                4'd0: seven_seg <= 7'b1000000;  // 0
                4'd1: seven_seg <= 7'b1111001;  // 1
                4'd2: seven_seg <= 7'b0100100;  // 2
                4'd3: seven_seg <= 7'b0110000;  // 3
                4'd4: seven_seg <= 7'b0011001;  // 4
                4'd5: seven_seg <= 7'b0010010;  // 5
                4'd6: seven_seg <= 7'b0000010;  // 6
                4'd7: seven_seg <= 7'b1111000;  // 7
                4'd8: seven_seg <= 7'b0000000;  // 8
                4'd9: seven_seg <= 7'b0010000;  // 9
                default: seven_seg <= 7'b0111111;  // Error display (-)
            endcase
        end
    end

endmodule