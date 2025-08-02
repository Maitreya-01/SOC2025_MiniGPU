`timescale 1ns/1ps

module tb_register;

  // Inputs
  reg clock = 0;
  reg reset = 0;
  reg enable = 0;
  reg reg_write_enable = 0;
  reg [7:0] alu_out = 0;
  reg [7:0] lsu_out = 0;
  reg [7:0] immediate = 0;
  reg [1:0] reg_input_mux = 0;
  reg [2:0] core_state = 0;
  reg [3:0] rs_address = 0;
  reg [3:0] rt_address = 0;
  reg [3:0] rd_address = 0;
  reg [7:0] block_id = 0;

  // Outputs
  wire [7:0] rs_data;
  wire [7:0] rt_data;

  // Instantiate the register module
  register uut (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .core_state(core_state),
    .reg_write_enable(reg_write_enable),
    .alu_out(alu_out),
    .lsu_out(lsu_out),
    .immediate(immediate),
    .reg_input_mux(reg_input_mux),
    .rs_address(rs_address),
    .rt_address(rt_address),
    .rd_address(rd_address),
    .block_id(block_id),
    .rs_data(rs_data),
    .rt_data(rt_data)
  );

  // Clock generation
  always #10 clock = ~clock;

  // Test sequence
  initial begin
    $display("Starting Register Testbench");

    // 1. Reset test
    reset = 1;
    #20;
    reset = 0;
    #20;

    if (rs_data == 8'h00 && rt_data == 8'h00)
      $display("Test 1: Reset behavior passed");
    else
      $display("Test 1: Reset behavior failed");

    // 2. BlockID write to register[13]
    enable = 1;
    reg_write_enable = 1;
    block_id = 8'b10101010;
    #20;

    rs_address = 4'd13;
    core_state = 3'b011; // ReadFromRF
    #20;

    if (rs_data == 8'b10101010)
      $display("Test 2: BlockID write to register[13] passed");
    else
      $display("Test 2: BlockID write to register[13] failed");

    // 3. ALU write to register[5]
    core_state = 3'b110; // WriteToRF
    rd_address = 4'd5;
    alu_out = 8'b00001111;
    reg_input_mux = 2'b00;
    #20;

    rs_address = 4'd5;
    core_state = 3'b011;
    #20;

    if (rs_data == 8'b00001111)
      $display("Test 3: ALU write to register[5] passed");
    else
      $display("Test 3: ALU write to register[5] failed");

    // 4. LSU write to register[6]
    core_state = 3'b110;
    rd_address = 4'd6;
    lsu_out = 8'b11110000;
    reg_input_mux = 2'b01;
    #20;

    rs_address = 4'd6;
    core_state = 3'b011;
    #20;

    if (rs_data == 8'b11110000)
      $display("Test 4: LSU write to register[6] passed");
    else
      $display("Test 4: LSU write to register[6] failed");

    // 5. Immediate write to register[7]
    core_state = 3'b110;
    rd_address = 4'd7;
    immediate = 8'b10100101;
    reg_input_mux = 2'b10;
    #20;

    rs_address = 4'd7;
    core_state = 3'b011;
    #20;

    if (rs_data == 8'b10100101)
      $display("Test 5: Immediate write to register[7] passed");
    else
      $display("Test 5: Immediate write to register[7] failed");

    $display("All tests completed.");
    #20;
    $finish;
  end

endmodule
