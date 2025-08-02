`timescale 1ns/1ps

module controller_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Consumer Interface
    reg consumer_read_valid;
    reg [7:0] consumer_read_address;
    wire consumer_read_ready;
    wire [15:0] consumer_read_data;
    reg consumer_write_valid;
    reg [7:0] consumer_write_address;
    reg [15:0] consumer_write_data;
    wire consumer_write_ready;

    // Memory Interface
    wire mem_read_valid;
    wire [7:0] mem_read_address;
    reg mem_read_ready;
    reg [15:0] mem_read_data;
    wire mem_write_valid;
    wire [7:0] mem_write_address;
    wire [15:0] mem_write_data;
    reg mem_write_ready;

    // DUT
    controller uut (
        .clk(clk),
        .reset(reset),
        .consumer_read_valid(consumer_read_valid),
        .consumer_read_address(consumer_read_address),
        .consumer_read_ready(consumer_read_ready),
        .consumer_read_data(consumer_read_data),
        .consumer_write_valid(consumer_write_valid),
        .consumer_write_address(consumer_write_address),
        .consumer_write_data(consumer_write_data),
        .consumer_write_ready(consumer_write_ready),
        .mem_read_valid(mem_read_valid),
        .mem_read_address(mem_read_address),
        .mem_read_ready(mem_read_ready),
        .mem_read_data(mem_read_data),
        .mem_write_valid(mem_write_valid),
        .mem_write_address(mem_write_address),
        .mem_write_data(mem_write_data),
        .mem_write_ready(mem_write_ready)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("---- Starting Controller Testbench ----");
        $dumpfile("controller_tb.vcd");
        $dumpvars(0, controller_tb);

        // Init
        clk = 0;
        reset = 1;
        consumer_read_valid = 0;
        consumer_read_address = 0;
        consumer_write_valid = 0;
        consumer_write_address = 0;
        consumer_write_data = 0;
        mem_read_ready = 0;
        mem_read_data = 16'hBEEF;
        mem_write_ready = 0;

        #10 reset = 0;

        // ---- Test 1: Read Transaction ----
        $display("Testing read transaction...");
        consumer_read_address = 8'hA5;
        consumer_read_valid = 1;

        #10 consumer_read_valid = 0;
        mem_read_ready = 1; // Mem returns data

        #10 mem_read_ready = 0;

        if (consumer_read_ready !== 1'b1 || consumer_read_data !== 16'hBEEF)
            $error("Read transaction failed: got ready=%b, data=%h", consumer_read_ready, consumer_read_data);
        else
            $display("Read transaction passed");

        // ---- Test 2: Write Transaction ----
        #10;
        $display("Testing write transaction...");
        consumer_write_valid = 1;
        consumer_write_address = 8'h3C;
        consumer_write_data = 16'hDEAD;

        #10;
        consumer_write_valid = 0;
        mem_write_ready = 1;

        #10;
        mem_write_ready = 0;

        if (consumer_write_ready !== 1'b1 || mem_write_valid !== 1'b1 ||
            mem_write_address !== 8'h3C || mem_write_data !== 16'hDEAD)
            $error("Write transaction failed: got ready=%b, addr=%h, data=%h", consumer_write_ready, mem_write_address, mem_write_data);
        else
            $display("Write transaction passed");

        #10;
        $display("---- Controller Testbench Finished ----");
        $stop;
    end

endmodule
