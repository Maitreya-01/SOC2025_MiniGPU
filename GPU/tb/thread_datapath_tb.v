`timescale 1ns / 1ps

module thread_datapath_tb;

  // Inputs
  reg clock;
  reg reset;
  reg enable;
  reg [15:0] instruction;
  reg [2:0] core_state;

  reg [3:0] rd_address;
  reg [3:0] rs_address;
  reg [3:0] rt_address;
  reg [7:0] immediate;
  reg [2:0] nzp_instr;
  reg reg_write_enable;
  reg mem_read_enable;
  reg mem_write_enable;
  reg nzp_write_enable;
  reg [1:0] reg_input_mux;
  reg [1:0] alu_select;
  reg pc_out_mux;
  reg decoded_ret;

  reg mem_read_ready;
  reg mem_write_ready;
  reg [7:0] mem_read_data;
  reg [7:0] block_id;

  // Outputs
  wire [7:0] thread_pc_out;
  wire [2:0] thread_nzp_out;
  wire [1:0] thread_lsu_state;
  wire [7:0] thread_alu_result;
  wire [7:0] thread_mem_write_data;
  wire [7:0] thread_mem_read_address;
  wire [7:0] thread_mem_write_address;

  // DUT instance
  thread_datapath uut (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .instruction(instruction),
    .core_state(core_state),
    .rd_address(rd_address),
    .rs_address(rs_address),
    .rt_address(rt_address),
    .immediate(immediate),
    .nzp_instr(nzp_instr),
    .reg_write_enable(reg_write_enable),
    .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable),
    .nzp_write_enable(nzp_write_enable),
    .reg_input_mux(reg_input_mux),
    .alu_select(alu_select),
    .pc_out_mux(pc_out_mux),
    .decoded_ret(decoded_ret),
    .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .mem_read_data(mem_read_data),
    .block_id(block_id),
    .thread_pc_out(thread_pc_out),
    .thread_nzp_out(thread_nzp_out),
    .thread_lsu_state(thread_lsu_state),
    .thread_alu_result(thread_alu_result),
    .thread_mem_write_data(thread_mem_write_data),
    .thread_mem_read_address(thread_mem_read_address),
    .thread_mem_write_address(thread_mem_write_address)
  );

  // Clock generation
  always #5 clock = ~clock;

    initial begin
    $dumpfile("thread_datapath_tb.vcd");
    $dumpvars(0, thread_datapath_tb);

    // Initialize inputs
    clock = 0;
    reset = 1;
    enable = 0;
    instruction = 16'h0000;
    core_state = 3'b000;

    rd_address = 4'h0;
    rs_address = 4'h1;
    rt_address = 4'h2;
    immediate = 8'h10;
    nzp_instr = 3'b001;
    reg_write_enable = 0;
    mem_read_enable = 0;
    mem_write_enable = 0;
    nzp_write_enable = 0;
    reg_input_mux = 2'b00;
    alu_select = 2'b00;
    pc_out_mux = 0;
    decoded_ret = 0;

    mem_read_ready = 1;
    mem_write_ready = 1;
    mem_read_data = 8'hFF;
    block_id = 8'h01;

    // Apply reset
    #10 reset = 0;
    enable = 1;

    // Test case 1: Simple ALU ADD (rs + rt)
    alu_select = 2'b00;
    reg_write_enable = 1;
    nzp_write_enable = 1;
    core_state = 3'b101;  // EXECUTE
    #10;
    
    // Expected ALU result depends on rs and rt values 
    // For demonstration, we'll assume you expect 8'h30
    if (thread_alu_result == 8'h30)
      $display("Test 1 (ALU ADD) PASSED");
    else
      $error("Test 1 (ALU ADD) FAILED: Expected 0x30, got 0x%0h", thread_alu_result);

    // Test case 2: Memory write
    mem_write_enable = 1;
    core_state = 3'b011;  // REQUEST
    #10;
    if (thread_mem_write_address != 8'h00) 
      $error("Test 2 (Mem Write) FAILED: Unexpected write address 0x%0h", thread_mem_write_address);
    else
      $display("Test 2 (Mem Write) PASSED");

    // Test case 3: Memory read
    mem_write_enable = 0;
    mem_read_enable = 1;
    core_state = 3'b011;  // REQUEST
    #10;
    if (thread_mem_read_address == 8'h00) 
      $display("Test 3 (Mem Read) PASSED");
    else
      $error("Test 3 (Mem Read) FAILED: Unexpected read address 0x%0h", thread_mem_read_address);

    // Finish simulation
    $finish;
  end


endmodule
