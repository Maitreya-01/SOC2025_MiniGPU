module top (
    input clock,
    input reset
);

  //===== Internal Wires and Control Signals =====

  // PC & NZP
  wire [2:0] nzp_out, alu_nzp;
  wire [7:0] next_pc;

  // ALU
  wire [7:0] alu_out;
  reg [1:0] alu_select = 2'b00;

  // Register File
  wire [7:0] rs_data, rt_data;
  reg        reg_write_enable = 1'b0;
  reg  [3:0] rs_address = 4'd0;
  reg  [3:0] rt_address = 4'd1;
  reg  [3:0] rd_address = 4'd2;
  reg  [1:0] reg_input_mux = 2'b00;
  wire [7:0] lsu_out;
  reg  [7:0] immediate = 8'd5;
  reg  [7:0] block_id = 8'd0;

  // LSU
  reg  mem_read_enable = 0;
  reg  mem_write_enable = 0;
  reg  mem_read_ready = 1;
  reg  mem_write_ready = 1;
  wire [7:0] mem_read_address, mem_write_address, mem_write_data;

  // PC + NZP
  reg enable = 1;
  reg [2:0] core_state = 3'b101;
  reg pc_out_mux = 0;
  reg [2:0] nzp_instr = 3'b001;
  reg nzp_write_enable = 1;
  reg [7:0] current_pc = 8'd0;

  //===== Instantiate ALU =====
  alu alu_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .core_state(core_state),
    .alu_select(alu_select),
    .operand_1(rs_data),
    .operand_2(rt_data),
    .alu_out(alu_out),
    .alu_nzp(alu_nzp)
  );

  //===== Instantiate Register File =====
  register regfile (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .reg_write_enable(reg_write_enable),
    .core_state(core_state),
    .rs_address(rs_address),
    .rt_address(rt_address),
    .rd_address(rd_address),
    .reg_input_mux(reg_input_mux),
    .alu_out(alu_out),
    .lsu_out(lsu_out),
    .immediate(immediate),
    .block_id(block_id),
    .rs_data(rs_data),
    .rt_data(rt_data)
  );

  //===== Instantiate PC + NZP =====
  pc_nzp pc_nzp_inst (
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
    .nzp(nzp_out),
    .next_pc(next_pc)
  );

  //===== Instantiate LSU =====
  lsu lsu_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable),
    .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state),
    .rs_out(rs_data),
    .rt_out(rt_data),
    .mem_read_data(8'd50), // You can connect to a memory block here
    .mem_read_address(mem_read_address),
    .mem_write_address(mem_write_address),
    .mem_write_data(mem_write_data),
    .lsu_out(lsu_out),
    .lsu_state()  // You can wire this out if needed
  );

endmodule 