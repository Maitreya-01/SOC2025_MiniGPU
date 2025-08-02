`timescale 1ns/1ps

module dcr_tb;

    // Inputs
    reg clk;
    reg reset;
    reg device_control_write_enable;
    reg [7:0] device_control_data;

    // Output
    wire [7:0] thread_count;

    // DUT Instantiation
    dcr uut (
        .clk(clk),
        .reset(reset),
        .device_control_write_enable(device_control_write_enable),
        .device_control_data(device_control_data),
        .thread_count(thread_count)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("---- Starting DCR Testbench ----");

        // Init
        clk = 0;
        reset = 1;
        device_control_write_enable = 0;
        device_control_data = 8'h00;

        // Apply reset
        #10 reset = 0;

        // Write 0xAB to DCR
        #10;
        device_control_write_enable = 1;
        device_control_data = 8'hAB;

        #10;
        device_control_write_enable = 0;

        #10;
        if (thread_count !== 8'hAB)
            $error("Write test failed: Expected 0xAB, got 0x%h", thread_count);
        else
            $display("Write test passed: thread_count = 0x%h", thread_count);

        reset = 1; #10; reset = 0; #10;
        if (thread_count !== 8'h00)
            $error("Reset test failed: Expected 0x00 after reset, got 0x%h", thread_count);
        else
            $display("Reset test passed: thread_count = 0x%h", thread_count);

        $display("---- DCR Testbench Complete ----");
        $finish;
    end

endmodule
