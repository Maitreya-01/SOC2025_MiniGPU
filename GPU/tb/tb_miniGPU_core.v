`timescale 1ns / 1ps

module tb_miniGPU_core;

  // Inputs
  reg clk = 0;
  reg reset;
  reg start;
  reg [7:0] block_id;
  reg [2:0] thread_count;
  reg program_mem_read_valid;
  reg [7:0] program_mem_read_address;
  reg data_mem_read_valid;
  reg [7:0] data_mem_read_address;
  reg data_mem_write_valid;
  reg [7:0] data_mem_write_address;
  reg [15:0] data_mem_write_data;
  reg [15:0] mem_read_data;
  reg mem_read_ready;
  reg mem_write_ready;

  // Outputs
  wire done;
  wire program_mem_read_ready;
  wire [15:0] program_mem_read_data;
  wire data_mem_read_ready;
  wire [15:0] data_mem_read_data;
  wire data_mem_write_ready;
  wire [2:0] core_state;
  wire [15:0] mem_read_address;
  wire mem_read_valid;
  wire [7:0] lsu_state_all;
  wire [15:0] debug_instruction;
  wire [15:0] mem_write_address;
  wire [15:0] mem_write_data;
  wire mem_write_valid;

  // Instantiate the Unit Under Test (UUT)
  miniGPU_core uut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done),
    .block_id(block_id),
    .thread_count(thread_count),
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
    .data_mem_write_ready(data_mem_write_ready),
    .mem_read_data(mem_read_data),
    .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state),
    .mem_read_address(mem_read_address),
    .mem_read_valid(mem_read_valid),
    .lsu_state_all(lsu_state_all),
    .debug_instruction(debug_instruction),
    .mem_write_address(mem_write_address),
    .mem_write_data(mem_write_data),
    .mem_write_valid(mem_write_valid)
  );

  // Clock generation
  always #5 clk = ~clk;  // 100 MHz

  initial begin
  // Initial values
  reset = 1;
  start = 0;
  block_id = 8'h01;
  thread_count = 3'b100;
  program_mem_read_valid = 0;
  program_mem_read_address = 8'h00;
  data_mem_read_valid = 0;
  data_mem_read_address = 8'h00;
  data_mem_write_valid = 0;
  data_mem_write_address = 8'h00;
  data_mem_write_data = 16'h0000;
  mem_read_data = 16'h1234;
  mem_read_ready = 1;
  mem_write_ready = 1;

  // Apply reset
  #20;
  reset = 0;

  // Start the GPU core
  #10;
  start = 1;
  #10;
  start = 0;

  // Provide mock memory data
  #50;
  mem_read_data = 16'hABCD;

  #200;

  // === TEST CASE 1: Done Signal Check ===
  if (done === 1'b1)
    $display("Test 1 (Done Signal): PASSED");
  else
    $error("Test 1 (Done Signal): FAILED — Expected 1, got %b", done);

  // === TEST CASE 2: Core State Check ===
  if (core_state == 3'b000) // Replace with expected final state
    $display("Test 2 (Core State): PASSED");
  else
    $error("Test 2 (Core State): FAILED — Expected 000, got %b", core_state);


  $stop;
end

endmodule