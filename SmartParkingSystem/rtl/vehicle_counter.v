// Vehicle Counter Module
// Uses D flip-flops for sequential counting
// Author: Akshat Raj (24BCE0043)

module vehicle_counter #(
    parameter MAX_CAPACITY = 10
)(
    input wire clk,
    input wire reset,
    input wire increment,
    input wire decrement,
    output reg parking_full,
    output reg [3:0] count
);

    // Sequential logic - D flip-flops
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 4'b0000;
            parking_full <= 1'b0;
        end
        else begin
            // Handle increment and decrement
            if (increment && !decrement) begin
                // Increment only if not at max capacity
                if (count < MAX_CAPACITY) begin
                    count <= count + 1;
                end
            end
            else if (decrement && !increment) begin
                // Decrement only if count > 0
                if (count > 0) begin
                    count <= count - 1;
                end
            end
            // If both increment and decrement, count stays same
            
            // Update parking full flag
            parking_full <= (count >= MAX_CAPACITY);
        end
    end

endmodule