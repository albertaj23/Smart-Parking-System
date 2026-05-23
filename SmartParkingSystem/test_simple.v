`timescale 1ns/1ps

module test_simple;
    reg clk, reset;
    reg entry_sensor1, entry_sensor2;
    wire increment;
    wire [3:0] count;
    wire parking_full;
    
    // Clock
    initial clk = 0;
    always #10 clk = ~clk;
    
    // Debounce
    wire entry1_clean, entry2_clean;
    sensor_debounce #(.DEBOUNCE_TIME(10)) db1 (
        .clk(clk), 
        .reset(reset),
        .sensor_in(entry_sensor1),
        .sensor_out(entry1_clean)
    );
    
    sensor_debounce #(.DEBOUNCE_TIME(10)) db2 (
        .clk(clk), 
        .reset(reset),
        .sensor_in(entry_sensor2),
        .sensor_out(entry2_clean)
    );
    
    // Validator
    wire valid_entry;
    dual_sensor_validator val (
        .clk(clk), 
        .reset(reset),
        .sensor1(entry1_clean),
        .sensor2(entry2_clean),
        .valid_detection(valid_entry)
    );
    
    // Edge detector
    edge_detector edge_inst (
        .clk(clk), 
        .reset(reset),
        .signal_in(valid_entry),
        .pulse_out(increment)
    );
    
    // Counter
    vehicle_counter #(.MAX_CAPACITY(10)) counter_inst (
        .clk(clk), 
        .reset(reset),
        .increment(increment),
        .decrement(1'b0),
        .parking_full(parking_full),
        .count(count)
    );
    
    // VCD dump
    initial begin
        $dumpfile("test_simple.vcd");
        $dumpvars(0, test_simple);
    end
    
    // Monitor
    always @(posedge clk) begin
        $display("Time=%0t | S1=%b S2=%b | S1_c=%b S2_c=%b | valid=%b | inc=%b | count=%d",
                 $time, entry_sensor1, entry_sensor2, entry1_clean, entry2_clean, 
                 valid_entry, increment, count);
    end
    
    // Test
    initial begin
        $display("=== Simple Entry Test ===");
        reset = 1;
        entry_sensor1 = 0;
        entry_sensor2 = 0;
        #100;
        reset = 0;
        #100;
        
        $display("\nActivating sensors...");
        entry_sensor1 = 1;
        #60;
        entry_sensor2 = 1;
        #120;
        entry_sensor1 = 0;
        #60;
        entry_sensor2 = 0;
        #500;
        
        $display("\nFinal count: %d (expected: 1)", count);
        
        if (count == 1)
            $display("✓ SUCCESS!");
        else
            $display("✗ FAILED!");
            
        #100;
        $finish;
    end
endmodule