`timescale 1ns / 1ps

module tb_pc_nzp;

  reg        clock = 0;
  reg        reset = 0;
  reg        enable = 0;
  reg  [2:0] core_state = 0;
  reg        pc_out_mux = 0;
  reg  [2:0] nzp_instr = 0;
  reg  [2:0] nzp_out = 0;
  reg  [7:0] current_pc = 0;
  reg  [7:0] immediate = 8'd100;
  reg        nzp_write_enable = 0;

  wire [2:0] nzp;
  wire [7:0] next_pc;

  // Instantiate DUT
  pc_nzp dut (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .core_state(core_state),
    .pc_out_mux(pc_out_mux),
    .nzp_instr(nzp_instr),
    .nzp_out(nzp_out),
    .current_pc(current_pc),
    .immediate(immediate),
    .nzp_write_enable(nzp_write_enable),
    .nzp(nzp),
    .next_pc(next_pc)
  );

  // Clock generation
  always #5 clock = ~clock;

  initial begin
    $display("---- Starting PC_NZP Testbench ----");

    // === Test Reset ===
    reset = 1; #10;
    reset = 0;

    enable = 1;
    core_state = 3'b101;
    current_pc = 8'd10;
    pc_out_mux = 1;

    // === Write NZP ===
    nzp_instr = 3'b010;
    nzp_out = 3'b010; // Z flag set
    nzp_write_enable = 1;
    core_state = 3'b110; #10;

    // === Test Case 1: Branch Taken (Z match) ===
    core_state = 3'b101;
    pc_out_mux = 1;
    nzp_instr = 3'b010;
    #10;

    if (next_pc == immediate)
      $display("Test 1 (Branch Taken): PASSED");
    else
      $error("Test 1 (Branch Taken): FAILED — Expected %0d, got %0d", immediate, next_pc);

    // === Test Case 2: Branch Not Taken ===
    nzp_instr = 3'b001; // N flag required, but NZP has Z set
    #10;

    if (next_pc == current_pc + 1)
      $display("Test 2 (Branch Not Taken): PASSED");
    else
      $error("Test 2 (Branch Not Taken): FAILED — Expected %0d, got %0d", current_pc + 1, next_pc);

    $display("---- End of PC_NZP Testbench ----");
    $stop;
  end
endmodule

