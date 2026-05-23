// Sensor Debounce Module
// Eliminates mechanical bounce and noise from sensors
// Author: Akshat Raj (24BCE0043)

module sensor_debounce #(
    parameter DEBOUNCE_TIME = 1000000  // Clock cycles for debounce
)(
    input wire clk,
    input wire reset,
    input wire sensor_in,
    output reg sensor_out
);

`ifdef SIMULATION
    // Simplified debounce for simulation - just a few cycle delay
    reg [2:0] shift_reg;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 3'b000;
            sensor_out <= 1'b0;
        end
        else begin
            shift_reg <= {shift_reg[1:0], sensor_in};
            // Output high if all 3 samples are high
            if (shift_reg == 3'b111)
                sensor_out <= 1'b1;
            else if (shift_reg == 3'b000)
                sensor_out <= 1'b0;
        end
    end
`else
    // Full debounce for real hardware
    reg [20:0] counter;
    reg sensor_sync_0, sensor_sync_1;

    // Synchronizer flip-flops to avoid metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sensor_sync_0 <= 1'b0;
            sensor_sync_1 <= 1'b0;
        end
        else begin
            sensor_sync_0 <= sensor_in;
            sensor_sync_1 <= sensor_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 21'b0;
            sensor_out <= 1'b0;
        end
        else begin
            if (sensor_sync_1 == sensor_out) begin
                // Input matches output, reset counter
                counter <= 21'b0;
            end
            else begin
                // Input different from output, count up
                counter <= counter + 1;
                if (counter >= DEBOUNCE_TIME) begin
                    // Debounce time elapsed, update output
                    sensor_out <= sensor_sync_1;
                    counter <= 21'b0;
                end
            end
        end
    end
`endif

endmodule