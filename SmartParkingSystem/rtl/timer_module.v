// Timer Module
// General purpose timer for time-based operations
// Author: Akshat Raj (24BCE0043)

module timer_module #(
    parameter MAX_COUNT = 50000000  // Default 1 second at 50MHz
)(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg timeout,
    output reg [31:0] count
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 32'b0;
            timeout <= 1'b0;
        end
        else if (enable) begin
            if (count >= MAX_COUNT) begin
                timeout <= 1'b1;
                count <= 32'b0;
            end
            else begin
                count <= count + 1;
                timeout <= 1'b0;
            end
        end
        else begin
            count <= 32'b0;
            timeout <= 1'b0;
        end
    end

endmodule