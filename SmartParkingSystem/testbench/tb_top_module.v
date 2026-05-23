`timescale 1ns/1ps

module tb_top_module;

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

    // Instantiate top module with reduced debounce time for simulation
    top_module #(
        .MAX_CAPACITY(8),
        .DEBOUNCE_TIME(10)  // Reduced for simulation
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

    // VCD dump
    initial begin
        $dumpfile("simulation/waveform_top.vcd");
        $dumpvars(0, tb_top_module);
    end

    // Test sequence
    initial begin
        $display("========== Top Module Integration Test ==========");
        
        // Initialize
        reset = 1;
        entry_sensor1 = 0;
        entry_sensor2 = 0;
        exit_sensor1 = 0;
        exit_sensor2 = 0;
        #100;
        reset = 0;
        #50;

        $display("\nInitial State:");
        $display("Available: %d, Count: %d, Full: %b", 
                 available_spots, current_count, parking_full);

        // Test 1: Single vehicle entry
        $display("\n--- Test 1: Vehicle Entry ---");
        simulate_entry();
        #500;
        $display("Available: %d, Count: %d, Full: %b", 
                 available_spots, current_count, parking_full);

        // Test 2: Multiple entries
        $display("\n--- Test 2: Multiple Entries ---");
        repeat(3) begin
            simulate_entry();
            #500;
        end
        $display("Available: %d, Count: %d, Full: %b", 
                 available_spots, current_count, parking_full);

        // Test 3: Vehicle exit
        $display("\n--- Test 3: Vehicle Exit ---");
        simulate_exit();
        #500;
        $display("Available: %d, Count: %d, Full: %b", 
                 available_spots, current_count, parking_full);

        // Test 4: Fill to capacity
        $display("\n--- Test 4: Fill to Capacity ---");
        repeat(4) begin
            simulate_entry();
            #500;
        end
        $display("Available: %d, Count: %d, Full: %b", 
                 available_spots, current_count, parking_full);

        $display("\n========== Test Complete ==========");
        #1000;
        $finish;
    end

    // Task to simulate vehicle entry
    task simulate_entry;
        begin
            entry_sensor1 = 1;
            #60;
            entry_sensor2 = 1;
            #100;
            entry_sensor1 = 0;
            #60;
            entry_sensor2 = 0;
        end
    endtask

    // Task to simulate vehicle exit
    task simulate_exit;
        begin
            exit_sensor1 = 1;
            #60;
            exit_sensor2 = 1;
            #100;
            exit_sensor1 = 0;
            #60;
            exit_sensor2 = 0;
        end
    endtask

endmodule