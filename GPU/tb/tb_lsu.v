`timescale 1ns / 1ps

module tb_lsu;

  reg         clock = 0;
  reg         reset = 0;
  reg         enable = 0;
  reg         mem_read_enable = 0;
  reg         mem_write_enable = 0;
  reg         mem_read_ready = 0;
  reg         mem_write_ready = 0;
  reg  [2:0]  core_state = 0;
  reg  [7:0]  rs_out = 0;
  reg  [7:0]  rt_out = 0;
  reg  [7:0]  mem_read_data = 8'hAB;

  wire [7:0] mem_read_address;
  wire [7:0] mem_write_address;
  wire [7:0] mem_write_data;
  wire [7:0] lsu_out;
  wire [1:0] lsu_state;

  // Instantiate DUT
  lsu dut (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable),
    .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state),
    .rs_out(rs_out),
    .rt_out(rt_out),
    .mem_read_data(mem_read_data),
    .mem_read_address(mem_read_address),
    .mem_write_address(mem_write_address),
    .mem_write_data(mem_write_data),
    .lsu_out(lsu_out),
    .lsu_state(lsu_state)
  );

  always #5 clock = ~clock;

  initial begin
    $display("---- Starting LSU Testbench ----");

    reset = 1; #10;
    reset = 0;

    enable = 1;

    // === LOAD TEST ===
    $display("LOAD START");
    mem_read_enable = 1;
    mem_write_enable = 0;
    rs_out = 8'h0A;
    core_state = 3'b011;  // REQUEST
    #10;

    core_state = 3'b101;  // WAIT
    #10;

    mem_read_ready = 1;
    #10;
    mem_read_ready = 0;

    core_state = 3'b110;  
    #10;

    $display("LSU Load Output: %h", lsu_out);
    if (lsu_out == mem_read_data)
      $display("Test 1 (LOAD): PASSED");
    else
      $error("Test 1 (LOAD): FAILED — Expected %h, got %h", mem_read_data, lsu_out);

    // === STORE TEST ===
    $display("STORE START");
    mem_read_enable = 0;
    mem_write_enable = 1;
    rs_out = 8'h0C;  // expected write address
    rt_out = 8'h55;  // expected write data
    core_state = 3'b011;
    #10;

    core_state = 3'b101;
    #10;

    mem_write_ready = 1;
    #10;
    mem_write_ready = 0;

    core_state = 3'b110;
    #10;

    $display("Write Addr: %h, Write Data: %h", mem_write_address, mem_write_data);
    if (mem_write_address == rs_out && mem_write_data == rt_out)
      $display("Test 2 (STORE): PASSED");
    else
      $error("Test 2 (STORE): FAILED — Addr: Expected %h, got %h | Data: Expected %h, got %h",
              rs_out, mem_write_address, rt_out, mem_write_data);

    $display("---- End of LSU Testbench ----");
    $stop;
  end
endmodule
