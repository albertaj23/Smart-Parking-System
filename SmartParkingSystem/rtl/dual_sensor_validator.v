// Dual Sensor Validator Module
// Validates vehicle detection using two sensors
// Prevents false alarms from stray animals
// Author: Akshat Raj (24BCE0043)

module dual_sensor_validator (
    input wire clk,
    input wire reset,
    input wire sensor1,
    input wire sensor2,
    output reg valid_detection
);

`ifdef SIMULATION
    // Simplified for simulation - level output (edge detector will create pulse)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_detection <= 1'b0;
        end
        else begin
            // Both sensors must be active
            if (sensor1 && sensor2) begin
                valid_detection <= 1'b1;
            end
            else begin
                valid_detection <= 1'b0;
            end
        end
    end
`else
    // Full validation for real hardware
    parameter MAX_TIME = 5000000;  // 100ms at 50MHz
    parameter MIN_TIME = 1000000;  // 20ms at 50MHz
    
    reg [22:0] timer;

    // State encoding
    localparam IDLE = 2'b00;
    localparam SENSOR1_ACTIVE = 2'b01;
    localparam BOTH_ACTIVE = 2'b10;
    localparam VALIDATED = 2'b11;

    reg [1:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next state and output logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            timer <= 23'b0;
            valid_detection <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    valid_detection <= 1'b0;
                    timer <= 23'b0;
                    if (sensor1) begin
                        next_state <= SENSOR1_ACTIVE;
                    end
                    else begin
                        next_state <= IDLE;
                    end
                end

                SENSOR1_ACTIVE: begin
                    if (sensor1 && sensor2) begin
                        next_state <= BOTH_ACTIVE;
                        timer <= timer + 1;
                    end
                    else if (!sensor1) begin
                        next_state <= IDLE;
                        timer <= 23'b0;
                    end
                    else begin
                        timer <= timer + 1;
                        if (timer >= MAX_TIME) begin
                            next_state <= IDLE;
                            timer <= 23'b0;
                        end
                        else begin
                            next_state <= SENSOR1_ACTIVE;
                        end
                    end
                end

                BOTH_ACTIVE: begin
                    timer <= timer + 1;
                    if (timer >= MIN_TIME) begin
                        valid_detection <= 1'b1;
                        next_state <= VALIDATED;
                    end
                    else if (!sensor1 || !sensor2) begin
                        next_state <= IDLE;
                        timer <= 23'b0;
                    end
                    else begin
                        next_state <= BOTH_ACTIVE;
                    end
                end

                VALIDATED: begin
                    valid_detection <= 1'b1;
                    if (!sensor1 && !sensor2) begin
                        next_state <= IDLE;
                        timer <= 23'b0;
                        valid_detection <= 1'b0;
                    end
                    else begin
                        next_state <= VALIDATED;
                    end
                end

                default: next_state <= IDLE;
            endcase
        end
    end
`endif

endmodule