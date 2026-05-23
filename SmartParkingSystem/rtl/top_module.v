// Top Module - Smart Parking System
// Integrates all submodules
// Author: Akshat Raj (24BCE0043)

module top_module #(
    parameter MAX_CAPACITY = 10,
    parameter DEBOUNCE_TIME = 1000000  // 20ms at 50MHz
)(
    input wire clk,
    input wire reset,
    input wire entry_sensor1,
    input wire entry_sensor2,
    input wire exit_sensor1,
    input wire exit_sensor2,
    output wire [3:0] available_spots,
    output wire [3:0] current_count,
    output wire parking_full,
    output wire entry_allowed,
    output wire [6:0] seven_seg_ones,
    output wire [6:0] seven_seg_tens
);

    // Internal signals
    wire entry_sensor1_clean, entry_sensor2_clean;
    wire exit_sensor1_clean, exit_sensor2_clean;
    wire valid_entry, valid_exit;
    wire increment, decrement;

    // Debounce entry sensors
    sensor_debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_entry1 (
        .clk(clk),
        .reset(reset),
        .sensor_in(entry_sensor1),
        .sensor_out(entry_sensor1_clean)
    );

    sensor_debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_entry2 (
        .clk(clk),
        .reset(reset),
        .sensor_in(entry_sensor2),
        .sensor_out(entry_sensor2_clean)
    );

    // Debounce exit sensors
    sensor_debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_exit1 (
        .clk(clk),
        .reset(reset),
        .sensor_in(exit_sensor1),
        .sensor_out(exit_sensor1_clean)
    );

    sensor_debounce #(.DEBOUNCE_TIME(DEBOUNCE_TIME)) debounce_exit2 (
        .clk(clk),
        .reset(reset),
        .sensor_in(exit_sensor2),
        .sensor_out(exit_sensor2_clean)
    );

    // Dual sensor validation for entry
    dual_sensor_validator entry_validator (
        .clk(clk),
        .reset(reset),
        .sensor1(entry_sensor1_clean),
        .sensor2(entry_sensor2_clean),
        .valid_detection(valid_entry)
    );

    // Dual sensor validation for exit
    dual_sensor_validator exit_validator (
        .clk(clk),
        .reset(reset),
        .sensor1(exit_sensor1_clean),
        .sensor2(exit_sensor2_clean),
        .valid_detection(valid_exit)
    );

    // Edge detectors for pulse generation
    edge_detector entry_edge (
        .clk(clk),
        .reset(reset),
        .signal_in(valid_entry),
        .pulse_out(increment)
    );

    edge_detector exit_edge (
        .clk(clk),
        .reset(reset),
        .signal_in(valid_exit),
        .pulse_out(decrement)
    );



    // Vehicle counter
    vehicle_counter #(.MAX_CAPACITY(MAX_CAPACITY)) counter (
        .clk(clk),
        .reset(reset),
        .increment(increment),
        .decrement(decrement),
        .parking_full(parking_full),
        .count(current_count)
    );

    // Finite State Machine
    parking_fsm #(.MAX_CAPACITY(MAX_CAPACITY)) fsm (
        .clk(clk),
        .reset(reset),
        .current_count(current_count),
        .parking_full(parking_full),
        .entry_allowed(entry_allowed)
    );


    // Calculate available spots
    assign available_spots = MAX_CAPACITY - current_count;

    // Display controllers for 7-segment
    // Extract ones and tens digits properly
    wire [3:0] ones_digit;
    wire [3:0] tens_digit;
    
    assign ones_digit = available_spots % 4'd10;
    assign tens_digit = available_spots / 4'd10;

    display_controller disp_ones (
        .clk(clk),
        .reset(reset),
        .value(ones_digit),
        .seven_seg(seven_seg_ones)
    );

    display_controller disp_tens (
        .clk(clk),
        .reset(reset),
        .value(tens_digit),
        .seven_seg(seven_seg_tens)
    );

endmodule

