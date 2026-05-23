// Testbench for Vehicle Counter Module
// Author: Akshat Raj (24BCE0043)

`timescale 1ns/1ps

module tb_vehicle_counter;

    reg clk;
    reg reset;
    reg increment;
    reg decrement;
    wire parking_full;
    wire [3:0] count;

    // Instantiate the module
    vehicle_counter #(.MAX_CAPACITY(5)) uut (
        .clk(clk),
        .reset(reset),
        .increment(increment),
        .decrement(decrement),
        .parking_full(parking_full),
        .count(count)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // VCD dump
    initial begin
        $dumpfile("simulation/waveform_counter.vcd");
        $dumpvars(0, tb_vehicle_counter);
    end

    // Test sequence
    initial begin
        $display("========== Vehicle Counter Test ==========");
        
        // Initialize
        reset = 1;
        increment = 0;
        decrement = 0;
        #50;
        reset = 0;
        #20;

        // Test 1: Increment
        $display("Test 1: Incrementing count");
        repeat(3) begin
            increment = 1;
            #20;
            increment = 0;
            #20;
            $display("Count: %d, Full: %b", count, parking_full);
        end

        // Test 2: Decrement
        $display("\nTest 2: Decrementing count");
        repeat(2) begin
            decrement = 1;
            #20;
            decrement = 0;
            #20;
            $display("Count: %d, Full: %b", count, parking_full);
        end

        // Test 3: Fill to capacity
        $display("\nTest 3: Fill to capacity");
        repeat(4) begin
            increment = 1;
            #20;
            increment = 0;
            #20;
            $display("Count: %d, Full: %b", count, parking_full);
        end

        // Test 4: Try to exceed capacity
        $display("\nTest 4: Attempt to exceed capacity");
        increment = 1;
        #20;
        increment = 0;
        #20;
        $display("Count: %d, Full: %b (should be at max)", count, parking_full);

        // Test 5: Simultaneous increment and decrement
        $display("\nTest 5: Simultaneous operations");
        increment = 1;
        decrement = 1;
        #20;
        increment = 0;
        decrement = 0;
        #20;
        $display("Count: %d (should be unchanged)", count);

        $display("\n========== Test Complete ==========");
        #100;
        $finish;
    end

endmodule