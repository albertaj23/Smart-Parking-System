`timescale 1ns/1ps

module tb_edge_detector;

    reg clk;
    reg reset;
    reg signal_in;
    wire pulse_out;

    // Instantiate the module
    edge_detector uut (
        .clk(clk),
        .reset(reset),
        .signal_in(signal_in),
        .pulse_out(pulse_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // VCD dump
    initial begin
        $dumpfile("simulation/waveform_edge.vcd");
        $dumpvars(0, tb_edge_detector);
    end

    // Test sequence
    initial begin
        $display("========== Edge Detector Test ==========");
        
        // Initialize
        reset = 1;
        signal_in = 0;
        #50;
        reset = 0;
        #20;

        // Test 1: Rising edge
        $display("Test 1: Rising edge detection");
        signal_in = 0;
        #40;
        signal_in = 1;
        #20;
        if (pulse_out)
            $display("✓ Rising edge detected");
        else
            $display("✗ Failed to detect rising edge");
        #20;

        // Test 2: Signal stays high
        $display("\nTest 2: Signal stays high (no new edge)");
        #40;
        if (!pulse_out)
            $display("✓ Correctly no pulse when signal stays high");
        else
            $display("✗ False pulse detected");

        // Test 3: Falling edge (should not trigger)
        $display("\nTest 3: Falling edge (should not trigger)");
        signal_in = 0;
        #40;
        if (!pulse_out)
            $display("✓ Correctly ignored falling edge");
        else
            $display("✗ False pulse on falling edge");

        // Test 4: Multiple rising edges
        $display("\nTest 4: Multiple rising edges");
        repeat(3) begin
            signal_in = 1;
            #20;
            signal_in = 0;
            #40;
        end

        $display("\n========== Test Complete ==========");
        #100;
        $finish;
    end

    // Monitor
    initial begin
        $monitor("Time=%0t | signal_in=%b | pulse_out=%b", 
                 $time, signal_in, pulse_out);
    end

endmodule