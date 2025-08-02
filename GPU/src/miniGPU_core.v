module miniGPU_core (
    input  wire         reset,
    input  wire         start,
    output wire         done,

    // Core configuration
    input  wire [7:0]   block_id,
    input  wire [2:0]   thread_count,

    // Program memory interface 
    input  wire         program_mem_read_valid,
    input  wire [7:0]   program_mem_read_address,
    output wire         program_mem_read_ready,
    output wire [15:0]  program_mem_read_data,

    // Data memory read interface
    input  wire         data_mem_read_valid,
    input  wire [7:0]   data_mem_read_address,
    output wire         data_mem_read_ready,
    output wire [15:0]  data_mem_read_data,

    // Data memory write interface
    input  wire         data_mem_write_valid,
    input  wire [7:0]   data_mem_write_address,
    input  wire [15:0]  data_mem_write_data,
    output wire         data_mem_write_ready,
	 
	 
	 
    // Top-level inputs
    input wire clk,
    input wire [15:0] mem_read_data,
    input wire mem_read_ready,
    input wire mem_write_ready,

    // Top-level outputs
    output wire [2:0] core_state,
    output wire [15:0] mem_read_address,
    output wire mem_read_valid,
    output wire [7:0] lsu_state_all, // 4 LSUs, 2 bits each
    output wire [15:0] debug_instruction,
    output wire [15:0] mem_write_address,
    output wire [15:0] mem_write_data,
    output wire mem_write_valid
);

// Internal wires for connecting modules
wire [1:0] fetcher_state_wire;
wire [15:0] instruction;
wire [7:0] current_pc_scheduler_out;
wire [7:0] next_pc_for_scheduler;

// Wires for decoder outputs 
wire [3:0] rd_address;
wire [3:0] rs_address;
wire [3:0] rt_address;
wire [7:0] immediate;
wire [2:0] nzp_instr;
wire reg_write_enable;
wire mem_read_enable;
wire mem_write_enable;
wire nzp_write_enable;
wire [1:0] reg_input_mux;
wire [1:0] alu_select;
wire pc_out_mux;
wire decoded_ret;

// Wires for connecting the 4 threads to the decoder outputs
wire [7:0] thread0_alu_result, thread1_alu_result, thread2_alu_result, thread3_alu_result;
wire [7:0] lsu_out_thread0, lsu_out_thread1, lsu_out_thread2, lsu_out_thread3;
wire [7:0] reg_rs_data_0, reg_rt_data_0;
wire [7:0] reg_rs_data_1, reg_rt_data_1;
wire [7:0] reg_rs_data_2, reg_rt_data_2;
wire [7:0] reg_rs_data_3, reg_rt_data_3;

// Wires for the PC/NZP outputs
wire [7:0] thread0_pc_out, thread1_pc_out, thread2_pc_out, thread3_pc_out;

// Wires for NZP flags
wire [2:0] thread0_alu_nzp_out, thread1_alu_nzp_out, thread2_alu_nzp_out, thread3_alu_nzp_out;
wire [2:0] thread0_pc_nzp_out, thread1_pc_nzp_out, thread2_pc_nzp_out, thread3_pc_nzp_out;

// Wires for LSU states
wire [1:0] lsu_state_0, lsu_state_1, lsu_state_2, lsu_state_3;
wire [7:0] lsu_mem_read_addr_0, lsu_mem_write_addr_0, lsu_mem_write_data_0;
wire [7:0] lsu_mem_read_addr_1, lsu_mem_write_addr_1, lsu_mem_write_data_1;
wire [7:0] lsu_mem_read_addr_2, lsu_mem_write_addr_2, lsu_mem_write_data_2;
wire [7:0] lsu_mem_read_addr_3, lsu_mem_write_addr_3, lsu_mem_write_data_3;

// Wires for the memory interface multiplexing logic
wire mem_read_enable_lsu; 
wire mem_write_enable_lsu; 

wire [7:0] fetcher_read_addr;
wire fetcher_read_valid;
wire [7:0] lsu_read_addr;
wire lsu_read_valid;
wire [7:0] lsu_write_addr;
wire [7:0] lsu_write_data;
wire lsu_write_valid;

assign lsu_state_all = {lsu_state_3, lsu_state_2, lsu_state_1, lsu_state_0};


assign debug_instruction = instruction;

assign mem_read_address = (mem_read_enable) ? {8'b0, lsu_mem_read_addr_0} : {8'b0, fetcher_read_addr};
assign mem_read_valid = (mem_read_enable) ? lsu_read_valid : fetcher_read_valid;
assign mem_write_address = (mem_write_enable) ? {8'b0, lsu_mem_write_addr_0} : 16'b0;
assign mem_write_data = (mem_write_enable) ? {8'b0, lsu_mem_write_data_0} : 16'b0;
assign mem_write_valid = mem_write_enable;

assign next_pc_for_scheduler = thread0_pc_out;


// Scheduler (core_fsm)
core_fsm core_fsm_inst (
    .clk(clk),
    .reset(reset),
    .start(start),
    .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable),
    .decoded_ret(decoded_ret),
    .fetcher_state(fetcher_state_wire),
    .lsu_state_all(lsu_state_all),
    .next_pc(next_pc_for_scheduler),
    .core_state(core_state),
    .current_pc(current_pc_scheduler_out),
    .done(done)
);

// Fetcher
fetcher fetcher_inst (
    .clk(clk),
    .reset(reset),
    .core_state(core_state),
    .current_pc(current_pc_scheduler_out),
    .mem_read_ready(mem_read_ready),
    .mem_read_data(mem_read_data[15:0]),
    .instruction(instruction),
    .mem_read_valid(fetcher_read_valid),
    .mem_read_address(fetcher_read_addr),
    .fetcher_state(fetcher_state_wire)
);

// Decoder
decoder decoder_inst (
    .clk(clk),
    .reset(reset),
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
    .decoded_ret(decoded_ret)
);


// Thread 0 Datapath
register register_inst_0 (
    .clock(clk), .reset(reset), .enable(1'b1), .reg_write_enable(reg_write_enable),
    .core_state(core_state), .rs_address(rs_address), .rt_address(rt_address),
    .rd_address(rd_address), .reg_input_mux(reg_input_mux), .alu_out(thread0_alu_result),
    .lsu_out(lsu_out_thread0), .immediate(immediate), .block_id(8'd0),
    .rs_data(reg_rs_data_0), .rt_data(reg_rt_data_0)
);

alu alu_inst_0 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .alu_select(alu_select),
    .operand_1(reg_rs_data_0), .operand_2(reg_rt_data_0), .alu_out(thread0_alu_result), .alu_nzp(thread0_alu_nzp_out)
);

pc_nzp pc_nzp_inst_0 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .pc_out_mux(pc_out_mux),
    .nzp_instr(nzp_instr), .nzp_out(thread0_alu_nzp_out), .current_pc(thread0_pc_out),
    .immediate(immediate), .nzp_write_enable(nzp_write_enable), .nzp(thread0_pc_nzp_out), .next_pc(thread0_pc_out)
);

lsu lsu_inst_0 (
    .clock(clk), .reset(reset), .enable(1'b1), .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable), .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state), .rs_out(reg_rs_data_0), .rt_out(reg_rt_data_0),
    .mem_read_data(mem_read_data[7:0]),
    .mem_read_address(lsu_mem_read_addr_0), .mem_write_address(lsu_mem_write_addr_0),
    .mem_write_data(lsu_mem_write_data_0), .lsu_out(lsu_out_thread0), .lsu_state(lsu_state_0)
);


// Thread 1 Datapath
register register_inst_1 (
    .clock(clk), .reset(reset), .enable(1'b1), .reg_write_enable(reg_write_enable),
    .core_state(core_state), .rs_address(rs_address), .rt_address(rt_address),
    .rd_address(rd_address), .reg_input_mux(reg_input_mux), .alu_out(thread1_alu_result),
    .lsu_out(lsu_out_thread1), .immediate(immediate), .block_id(8'd1),
    .rs_data(reg_rs_data_1), .rt_data(reg_rt_data_1)
);

alu alu_inst_1 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .alu_select(alu_select),
    .operand_1(reg_rs_data_1), .operand_2(reg_rt_data_1), .alu_out(thread1_alu_result), .alu_nzp(thread1_alu_nzp_out)
);

pc_nzp pc_nzp_inst_1 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .pc_out_mux(pc_out_mux),
    .nzp_instr(nzp_instr), .nzp_out(thread1_alu_nzp_out), .current_pc(thread1_pc_out),
    .immediate(immediate), .nzp_write_enable(nzp_write_enable), .nzp(thread1_pc_nzp_out), .next_pc(thread1_pc_out)
);

lsu lsu_inst_1 (
    .clock(clk), .reset(reset), .enable(1'b1), .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable), .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state), .rs_out(reg_rs_data_1), .rt_out(reg_rt_data_1),
    .mem_read_data(mem_read_data[7:0]),
    .mem_read_address(lsu_mem_read_addr_1), .mem_write_address(lsu_mem_write_addr_1),
    .mem_write_data(lsu_mem_write_data_1), .lsu_out(lsu_out_thread1), .lsu_state(lsu_state_1)
);

// Thread 2 Datapath
register register_inst_2 (
    .clock(clk), .reset(reset), .enable(1'b1), .reg_write_enable(reg_write_enable),
    .core_state(core_state), .rs_address(rs_address), .rt_address(rt_address),
    .rd_address(rd_address), .reg_input_mux(reg_input_mux), .alu_out(thread2_alu_result),
    .lsu_out(lsu_out_thread2), .immediate(immediate), .block_id(8'd2),
    .rs_data(reg_rs_data_2), .rt_data(reg_rt_data_2)
);

alu alu_inst_2 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .alu_select(alu_select),
    .operand_1(reg_rs_data_2), .operand_2(reg_rt_data_2), .alu_out(thread2_alu_result), .alu_nzp(thread2_alu_nzp_out)
);

pc_nzp pc_nzp_inst_2 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .pc_out_mux(pc_out_mux),
    .nzp_instr(nzp_instr), .nzp_out(thread2_alu_nzp_out), .current_pc(thread2_pc_out),
    .immediate(immediate), .nzp_write_enable(nzp_write_enable), .nzp(thread2_pc_nzp_out), .next_pc(thread2_pc_out)
);

lsu lsu_inst_2 (
    .clock(clk), .reset(reset), .enable(1'b1), .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable), .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state), .rs_out(reg_rs_data_2), .rt_out(reg_rt_data_2),
    .mem_read_data(mem_read_data[7:0]),
    .mem_read_address(lsu_mem_read_addr_2), .mem_write_address(lsu_mem_write_addr_2),
    .mem_write_data(lsu_mem_write_data_2), .lsu_out(lsu_out_thread2), .lsu_state(lsu_state_2)
);

// Thread 3 Datapath
register register_inst_3 (
    .clock(clk), .reset(reset), .enable(1'b1), .reg_write_enable(reg_write_enable),
    .core_state(core_state), .rs_address(rs_address), .rt_address(rt_address),
    .rd_address(rd_address), .reg_input_mux(reg_input_mux), .alu_out(thread3_alu_result),
    .lsu_out(lsu_out_thread3), .immediate(immediate), .block_id(8'd3),
    .rs_data(reg_rs_data_3), .rt_data(reg_rt_data_3)
);

alu alu_inst_3 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .alu_select(alu_select),
    .operand_1(reg_rs_data_3), .operand_2(reg_rt_data_3), .alu_out(thread3_alu_result), .alu_nzp(thread3_alu_nzp_out)
);

pc_nzp pc_nzp_inst_3 (
    .clock(clk), .reset(reset), .enable(1'b1), .core_state(core_state), .pc_out_mux(pc_out_mux),
    .nzp_instr(nzp_instr), .nzp_out(alu_nzp_out_3), .current_pc(thread3_pc_out),
    .immediate(immediate), .nzp_write_enable(nzp_write_enable), .nzp(thread3_pc_nzp_out), .next_pc(thread3_pc_out)
);

lsu lsu_inst_3 (
    .clock(clk), .reset(reset), .enable(1'b1), .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable), .mem_read_ready(mem_read_ready),
    .mem_write_ready(mem_write_ready),
    .core_state(core_state), .rs_out(reg_rs_data_3), .rt_out(reg_rt_data_3),
    .mem_read_data(mem_read_data[7:0]),
    .mem_read_address(lsu_mem_read_addr_3), .mem_write_address(lsu_mem_write_addr_3),
    .mem_write_data(lsu_mem_write_data_3), .lsu_out(lsu_out_thread3), .lsu_state(lsu_state_3)
);

endmodule
