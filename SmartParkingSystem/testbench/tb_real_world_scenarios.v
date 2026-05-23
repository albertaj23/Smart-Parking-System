`timescale 1ns/1ps

module tb_real_world_scenarios;

    reg clk;
    reg reset;
    reg entry_sensor1, entry_sensor2;
    reg exit_sensor1, exit_sensor2;
    wire [3:0] available_spots;
    wire [3:0] current_count;
    wire parking_full;
    wire entry_allowed;
    wire [6:0] seven_seg_ones;
    wire [6:0] seven_seg_tens;

    integer pass_count = 0;
    integer fail_count = 0;

    // Instantiate top module
    top_module #(
        .MAX_CAPACITY(10),
        .DEBOUNCE_TIME(10)  // Reduced for simulation speed
    ) uut (
        .clk(clk),
        .reset(reset),
        .entry_sensor1(entry_sensor1),
        .entry_sensor2(entry_sensor2),
        .exit_sensor1(exit_sensor1),
        .exit_sensor2(exit_sensor2),
        .available_spots(available_spots),
        .current_count(current_count),
        .parking_full(parking_full),
        .entry_allowed(entry_allowed),
        .seven_seg_ones(seven_seg_ones),
        .seven_seg_tens(seven_seg_tens)
    );

    // Clock generation - 50MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // VCD dump for waveform viewing
    initial begin
        $dumpfile("simulation/waveform_full.vcd");
        $dumpvars(0, tb_real_world_scenarios);
    end

    // Main test sequence
    initial begin
        $display("\n");
        $display("╔════════════════════════════════════════════════════╗");
        $display("║   SMART PARKING SYSTEM - COMPREHENSIVE TEST       ║");
        $display("║   Author: Akshat Raj (24BCE0043)                  ║");
        $display("╚════════════════════════════════════════════════════╝");
        $display("\n");

        // Initialize
        initialize();

        // Run all tests
        test_01_system_reset();
        test_02_single_entry();
        test_03_single_exit();
        test_04_multiple_entries();
        test_05_multiple_exits();
        test_06_fill_to_capacity();
        test_07_entry_when_full();
        test_08_exit_when_full();
        test_09_simultaneous_operations();
        test_10_false_alarm_single_sensor();
        test_11_sensor_noise();
        test_12_rapid_entries();
        test_13_emergency_reset();
        test_14_empty_parking_exit();
        test_15_alternating_operations();

        // Display results
        display_results();

        #1000;
        $finish;
    end

    // Initialize system
    task initialize;
        begin
            reset = 1;
            entry_sensor1 = 0;
            entry_sensor2 = 0;
            exit_sensor1 = 0;
            exit_sensor2 = 0;
            #100;
            reset = 0;
            #50;
        end
    endtask

    // TEST 1: System Reset
    task test_01_system_reset;
        begin
            $display("\n[TEST 1] System Initialization and Reset");
            $display("─────────────────────────────────────────");
            reset = 1;
            #100;
            reset = 0;
            #50;
            check_state(10, 0, 0, "System Reset");
        end
    endtask

    // TEST 2: Single Vehicle Entry
    task test_02_single_entry;
        begin
            $display("\n[TEST 2] Single Vehicle Entry");
            $display("─────────────────────────────────────────");
            simulate_vehicle_entry();
            #500;
            check_state(9, 1, 0, "Single Entry");
        end
    endtask

    // TEST 3: Single Vehicle Exit
    task test_03_single_exit;
        begin
            $display("\n[TEST 3] Single Vehicle Exit");
            $display("─────────────────────────────────────────");
            simulate_vehicle_exit();
            #500;
            check_state(10, 0, 0, "Single Exit");
        end
    endtask

    // TEST 4: Multiple Sequential Entries
    task test_04_multiple_entries;
        begin
            $display("\n[TEST 4] Multiple Sequential Entries (5 vehicles)");
            $display("─────────────────────────────────────────");
            repeat(5) begin
                simulate_vehicle_entry();
                #400;
            end
            check_state(5, 5, 0, "5 Sequential Entries");
        end
    endtask

    // TEST 5: Multiple Sequential Exits
    task test_05_multiple_exits;
        begin
            $display("\n[TEST 5] Multiple Sequential Exits (2 vehicles)");
            $display("─────────────────────────────────────────");
            repeat(2) begin
                simulate_vehicle_exit();
                #400;
            end
            check_state(7, 3, 0, "2 Sequential Exits");
        end
    endtask

    // TEST 6: Fill to Capacity
    task test_06_fill_to_capacity;
        begin
            $display("\n[TEST 6] Fill Parking to Maximum Capacity");
            $display("─────────────────────────────────────────");
            repeat(7) begin
                simulate_vehicle_entry();
                #400;
            end
            check_state(0, 10, 1, "Parking Full");
        end
    endtask

    // TEST 7: Entry Attempt When Full
    task test_07_entry_when_full;
        begin
            $display("\n[TEST 7] Attempt Entry When Full");
            $display("─────────────────────────────────────────");
            simulate_vehicle_entry();
            #500;
            check_state(0, 10, 1, "Entry Blocked - Still Full");
        end
    endtask

    // TEST 8: Exit When Full
    task test_08_exit_when_full;
        begin
            $display("\n[TEST 8] Exit When Parking is Full");
            $display("─────────────────────────────────────────");
            simulate_vehicle_exit();
            #500;
            check_state(1, 9, 0, "Exit from Full - Space Available");
        end
    endtask

    // TEST 9: Simultaneous Entry and Exit
    task test_09_simultaneous_operations;
        begin
            $display("\n[TEST 9] Simultaneous Entry and Exit");
            $display("─────────────────────────────────────────");
            fork
                simulate_vehicle_entry();
                #100 simulate_vehicle_exit();
            join
            #600;
            check_state(1, 9, 0, "Simultaneous Operations");
        end
    endtask

    // TEST 10: False Alarm - Single Sensor (Stray Dog)
    task test_10_false_alarm_single_sensor;
        begin
            $display("\n[TEST 10] False Alarm Test - Single Sensor Trigger");
            $display("─────────────────────────────────────────");
            $display("Simulating: Stray dog passes sensor 1 only");
            entry_sensor1 = 1;
            #50;
            entry_sensor1 = 0;
            #500;
            check_state(1, 9, 0, "False Alarm Rejected");
        end
    endtask

    // TEST 11: Sensor Noise/Bouncing
    task test_11_sensor_noise;
        begin
            $display("\n[TEST 11] Sensor Noise Immunity Test");
            $display("─────────────────────────────────────────");
            $display("Simulating: Noisy sensor with bouncing");
            // Simulate bouncing
            entry_sensor1 = 1;
            #5 entry_sensor1 = 0;
            #5 entry_sensor1 = 1;
            #5 entry_sensor1 = 0;
            #5 entry_sensor1 = 1;
            entry_sensor2 = 1;
            #150;
            entry_sensor1 = 0;
            entry_sensor2 = 0;
            #500;
            check_state(0, 10, 1, "Valid Entry Despite Noise");
        end
    endtask

    // TEST 12: Rapid Sequential Entries (Rush Hour)
    task test_12_rapid_entries;
        begin
            $display("\n[TEST 12] Rush Hour Simulation - Rapid Entries");
            $display("─────────────────────────────────────────");
            // Empty parking first
            reset = 1;
            #100;
            reset = 0;
            #50;
            
            repeat(5) begin
                simulate_vehicle_entry();
                #300;  // Shorter delay between vehicles
            end
            check_state(5, 5, 0, "Rush Hour - 5 Rapid Entries");
        end
    endtask

    // TEST 13: Emergency Reset During Operation
    task test_13_emergency_reset;
        begin
            $display("\n[TEST 13] Emergency System Reset");
            $display("─────────────────────────────────────────");
            $display("Performing emergency reset during operation");
            reset = 1;
            #150;
            reset = 0;
            #50;
            check_state(10, 0, 0, "Emergency Reset Complete");
        end
    endtask

    // TEST 14: Exit from Empty Parking
    task test_14_empty_parking_exit;
        begin
            $display("\n[TEST 14] Exit Attempt from Empty Parking");
            $display("─────────────────────────────────────────");
            simulate_vehicle_exit();
            #500;
            check_state(10, 0, 0, "Count Remains at Zero");
        end
    endtask

    // TEST 15: Alternating Entry/Exit
    task test_15_alternating_operations;
        begin
            $display("\n[TEST 15] Alternating Entry and Exit Operations");
            $display("─────────────────────────────────────────");
            repeat(3) begin
                simulate_vehicle_entry();
                #400;
                simulate_vehicle_entry();
                #400;
                simulate_vehicle_exit();
                #400;
            end
            check_state(7, 3, 0, "Alternating Operations");
        end
    endtask

    // Task: Simulate valid vehicle entry
    task simulate_vehicle_entry;
        begin
            entry_sensor1 = 1;
            #60;
            entry_sensor2 = 1;
            #120;
            entry_sensor1 = 0;
            #60;
            entry_sensor2 = 0;
        end
    endtask

    // Task: Simulate valid vehicle exit
    task simulate_vehicle_exit;
        begin
            exit_sensor1 = 1;
            #60;
            exit_sensor2 = 1;
            #120;
            exit_sensor1 = 0;
            #60;
            exit_sensor2 = 0;
        end
    endtask

    // Task: Check system state
    task check_state;
        input [3:0] expected_spots;
        input [3:0] expected_count;
        input expected_full;
        input [255:0] test_name;
        begin
            #10;  // Small delay for signals to settle
            if (available_spots == expected_spots && 
                current_count == expected_count && 
                parking_full == expected_full) begin
                $display("✓ PASS: %0s", test_name);
                $display("  Available: %0d | Count: %0d | Full: %0b", 
                         available_spots, current_count, parking_full);
                pass_count = pass_count + 1;
            end
            else begin
                $display("✗ FAIL: %0s", test_name);
                $display("  Expected -> Available: %0d | Count: %0d | Full: %0b",
                         expected_spots, expected_count, expected_full);
                $display("  Got      -> Available: %0d | Count: %0d | Full: %0b",
                         available_spots, current_count, parking_full);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Display final results
    task display_results;
        begin
            $display("\n");
            $display("╔════════════════════════════════════════════════════╗");
            $display("║              TEST RESULTS SUMMARY                  ║");
            $display("╠════════════════════════════════════════════════════╣");
            $display("║  Total Tests: %2d                                   ║", pass_count + fail_count);
            $display("║  Tests Passed: %2d                                  ║", pass_count);
            $display("║  Tests Failed: %2d                                  ║", fail_count);
            $display("╠════════════════════════════════════════════════════╣");
            if (fail_count == 0) begin
                $display("║           ✓ ALL TESTS PASSED! ✓                   ║");
            end
            else begin
                $display("║           ✗ SOME TESTS FAILED ✗                   ║");
            end
            $display("╚════════════════════════════════════════════════════╝");
            $display("\n");
        end
    endtask

    // Continuous monitoring
    always @(posedge clk) begin
        if (current_count > 10) begin
            $display("ERROR: Counter exceeded maximum capacity!");
            $finish;
        end
    end

endmodule