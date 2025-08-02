module thread_datapath (
    // Inputs from the top-level module
    input wire clock,
    input wire reset,
    input wire enable,
    input wire [15:0] instruction,
    input wire [2:0] core_state,

    // Control signals from the Decoder
    input wire [3:0] rd_address,
    input wire [3:0] rs_address,
    input wire [3:0] rt_address,
    input wire [7:0] immediate,
    input wire [2:0] nzp_instr,
    input wire reg_write_enable,
    input wire mem_read_enable,
    input wire mem_write_enable,
    input wire nzp_write_enable,
    input wire [1:0] reg_input_mux,
    input wire [1:0] alu_select,
    input wire pc_out_mux,
    input wire decoded_ret,
    
    // Inputs from top-level for LSU
    input wire mem_read_ready,
    input wire mem_write_ready,
    input wire [7:0] mem_read_data, // Corrected to 8-bit to match lsu.v
    input wire [7:0] block_id,

    // Outputs to the top-level module
    output wire [7:0] thread_pc_out, // PC output for scheduler (corrected to 8-bit)
    output wire [2:0] thread_nzp_out, // NZP flags for branch condition
    output wire [1:0] thread_lsu_state, // LSU FSM state
    output wire [7:0] thread_alu_result, // ALU output for debugging/monitoring
    output wire [7:0] thread_mem_write_data, // Data to be written to memory from LSU
    output wire [7:0] thread_mem_read_address,
    output wire [7:0] thread_mem_write_address
);

  //===== Internal Wires and Control Signals =====
  wire [7:0] alu_out_data;
  wire [7:0] lsu_out_data;
  wire [7:0] rs_data, rt_data;
  wire [2:0] alu_nzp;
  wire [7:0] next_pc;

  // Assign output wires
  assign thread_alu_result = alu_out_data;
  assign thread_nzp_out = alu_nzp;
  assign thread_pc_out = next_pc;

  //===== Instantiate ALU =====
  alu alu_inst (
    .clock(clock),
    .reset(reset),
    .enable(enable),
    .core_state(core_state),
    .alu_select(alu_select),
    .operand_1(rs_data),
    .operand_2(rt_data),
    .alu_out(alu_out_data),
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
    .alu_out(alu_out_data),
    .lsu_out(lsu_out_data),
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
    .nzp_out(alu_nzp), // Connect the ALU's NZP output to the PC_NZP's NZP input
    .current_pc(thread_pc_out), // Use the output from the PC_NZP module as the current PC for next cycle
    .immediate(immediate),
    .nzp_write_enable(nzp_write_enable),
    .nzp(thread_nzp_out),
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
    .mem_read_data(mem_read_data),
    .mem_read_address(thread_mem_read_address),
    .mem_write_address(thread_mem_write_address),
    .mem_write_data(thread_mem_write_data),
    .lsu_out(lsu_out_data),
    .lsu_state(thread_lsu_state)
  );
endmodule 