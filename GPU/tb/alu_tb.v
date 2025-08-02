`timescale 1ns / 1ps

module alu_tb;

  reg clock = 0;
  reg reset = 0;
  reg enable = 0;
  reg [7:0] operand_1 = 0;
  reg [7:0] operand_2 = 0;
  reg [1:0] alu_select = 0;
  reg [2:0] core_state = 3'b000;

  wire [7:0] alu_out;
  wire [2:0] alu_nzp;

  // Instantiate the ALU
  alu uut (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .alu_select(alu_select),
    .core_state(core_state),
    .alu_out(alu_out),
    .alu_nzp(alu_nzp)
  );

  // Clock generation
  always #10 clock = ~clock;

  initial begin
    $display("Starting ALU Testbench");

    // Reset test
    #100;
    reset = 1;
    #20;
    reset = 0;
    #20;
    if (alu_out == 8'b00000000 && alu_nzp == 3'b000)
      $display("Test 1 (Reset) Passed");
    else
      $display("Test 1 (Reset) Failed");

    // Enable and set core state for ALU operation
    enable = 1;
    core_state = 3'b101;

    // Test 2: ADD 25 + 11 = 36
    operand_1 = 8'd25;
    operand_2 = 8'd11;
    alu_select = 2'b00;
    #40;
    if (alu_out == 8'd36 && alu_nzp == 3'b100)
      $display("Test 2 (ADD) Passed");
    else
      $display("Test 2 (ADD) Failed");

    // Test 3: SUB 25 - 11 = 14
    alu_select = 2'b01;
    #40;
    if (alu_out == 8'd14 && alu_nzp == 3'b100)
      $display("Test 3 (SUB) Passed");
    else
      $display("Test 3 (SUB) Failed");

    // Test 4: MUL 5 * 11 = 55
    operand_1 = 8'd5;
    operand_2 = 8'd11;
    alu_select = 2'b10;
    #40;
    if (alu_out == 8'd55 && alu_nzp == 3'b100)
      $display("Test 4 (MUL) Passed");
    else
      $display("Test 4 (MUL) Failed");

    // Test 5: DIV 11 / 5 = 2
    operand_1 = 8'd11;
    operand_2 = 8'd5;
    alu_select = 2'b11;
    #40;
    if (alu_out == 8'd2 && alu_nzp == 3'b100)
      $display("Test 5 (DIV) Passed");
    else
      $display("Test 5 (DIV) Failed");

    $display("All tests completed.");
    #40;
    $stop;
  end

endmodule
