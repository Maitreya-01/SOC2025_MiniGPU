`timescale 1ns / 1ps

module gpu_tb;

  reg clk;
  reg reset;
  reg start;
  wire done;

  reg device_control_write_enable;
  reg [7:0] device_control_data;

  wire program_mem_read_valid;
  wire [7:0] program_mem_read_address;
  reg program_mem_read_ready;
  reg [15:0] program_mem_read_data;

  wire [3:0] data_mem_read_valid;
  wire [7:0] data_mem_read_address;
  reg [3:0] data_mem_read_ready;
  reg [7:0] data_mem_read_data;
  wire [3:0] data_mem_write_valid;
  wire [7:0] data_mem_write_address;
  wire [7:0] data_mem_write_data;
  reg [3:0] data_mem_write_ready;

  gpu uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done),
    .device_control_write_enable(device_control_write_enable),
    .device_control_data(device_control_data),
    .program_mem_read_valid(program_mem_read_valid),
    .program_mem_read_address(program_mem_read_address),
    .program_mem_read_ready(program_mem_read_ready),
    .program_mem_read_data(program_mem_read_data),
    .data_mem_read_valid(data_mem_read_valid),
    .data_mem_read_address(data_mem_read_address),
    .data_mem_read_ready(data_mem_read_ready),
    .data_mem_read_data(data_mem_read_data),
    .data_mem_write_valid(data_mem_write_valid),
    .data_mem_write_address(data_mem_write_address),
    .data_mem_write_data(data_mem_write_data),
    .data_mem_write_ready(data_mem_write_ready)
  );

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $display("---- Starting GPU Testbench ----");

    // Initialize
    reset = 1;
    start = 0;
    device_control_write_enable = 0;
    device_control_data = 8'd8;
    program_mem_read_ready = 1;
    data_mem_read_ready = 4'b1111;
    data_mem_write_ready = 4'b1111;

    // Reset
    #10 reset = 0;

    // Write device control
    #10 device_control_write_enable = 1;
    #10 device_control_write_enable = 0;

    // Start GPU
    #10 start = 1;
    #10 start = 0;

    #150;
    if (done === 1'b1) begin
      $display("Test PASSED: GPU signaled done.");
    end else begin
      $error("Test FAILED: GPU did not complete execution in expected time.");
    end

    $display("---- GPU Testbench Complete ----");
    $finish;
  end

endmodule

