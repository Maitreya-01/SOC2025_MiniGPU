`timescale 1ns / 1ps

module tb_decoder;

    // Inputs
    reg clk;
    reg reset;
    reg [15:0] instruction;
    reg [2:0] core_state;

    // Outputs
    wire [3:0] rd_address, rs_address, rt_address;
    wire [7:0] immediate;
    wire [2:0] nzp_instr;

    wire reg_write_enable, mem_read_enable, mem_write_enable, nzp_write_enable;
    wire [1:0] reg_input_mux, alu_select;
    wire pc_out_mux, decoded_ret;

    // Instantiate the decoder
    decoder uut (
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

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    task decode_instruction(
        input [15:0] instr,
        input [3:0] exp_rd, exp_rs, exp_rt,
        input [7:0] exp_imm,
        input [2:0] exp_nzp,
        input exp_reg_write, exp_mem_read, exp_mem_write, exp_nzp_write,
        input [1:0] exp_mux, exp_alu,
        input exp_pc_mux, exp_ret
    );
    begin
        instruction = instr;
        core_state = 3'b010; #10;
        core_state = 3'b000; #10;

        if (rd_address !== exp_rd || rs_address !== exp_rs || rt_address !== exp_rt ||
            immediate !== exp_imm || nzp_instr !== exp_nzp ||
            reg_write_enable !== exp_reg_write || mem_read_enable !== exp_mem_read ||
            mem_write_enable !== exp_mem_write || nzp_write_enable !== exp_nzp_write ||
            reg_input_mux !== exp_mux || alu_select !== exp_alu ||
            pc_out_mux !== exp_pc_mux || decoded_ret !== exp_ret) begin
            $display("Test failed for instruction %b", instr);
            $display(" Got  rd=%d rs=%d rt=%d imm=%d nzp=%b reg_wr=%b mem_rd=%b mem_wr=%b nzp_wr=%b mux=%b alu=%b pc_mux=%b ret=%b",
                rd_address, rs_address, rt_address, immediate, nzp_instr,
                reg_write_enable, mem_read_enable, mem_write_enable, nzp_write_enable,
                reg_input_mux, alu_select, pc_out_mux, decoded_ret);
            $display("  Expect  rd=%d rs=%d rt=%d imm=%d nzp=%b reg_wr=%b mem_rd=%b mem_wr=%b nzp_wr=%b mux=%b alu=%b pc_mux=%b ret=%b",
                exp_rd, exp_rs, exp_rt, exp_imm, exp_nzp,
                exp_reg_write, exp_mem_read, exp_mem_write, exp_nzp_write,
                exp_mux, exp_alu, exp_pc_mux, exp_ret);
        end else begin
            $display("Instruction %b decoded successfully", instr);
        end
    end
    endtask

    initial begin
        $display("Starting decoder testbench...");
        $dumpfile("tb_decoder.vcd");
        $dumpvars(0, tb_decoder);

        reset = 1;
        instruction = 16'b0;
        core_state = 3'b000;

        #12 reset = 0;

        // ADD R1, R2, R3
        decode_instruction(16'b0011_0001_0010_0011,
                           4'd1, 4'd2, 4'd3, 8'd0, 3'b000,
                           1, 0, 0, 0, 2'b00, 2'b00, 0, 0);

        // SUB R4, R5, R6
        decode_instruction(16'b0100_0100_0101_0110,
                           4'd4, 4'd5, 4'd6, 8'd0, 3'b000,
                           1, 0, 0, 0, 2'b00, 2'b01, 0, 0);

        // LDR R8, R9, R10
        decode_instruction(16'b0111_1000_1001_1010,
                           4'd8, 4'd9, 4'd10, 8'd0, 3'b000,
                           1, 1, 0, 0, 2'b01, 2'b00, 0, 0);

        // STR R1, R2, R3
        decode_instruction(16'b1000_0001_0010_0011,
                           4'd1, 4'd2, 4'd3, 8'd0, 3'b000,
                           0, 0, 1, 0, 2'b00, 2'b00, 0, 0);

        // CONST R3, #3
        decode_instruction(16'b1001_0011_00000011,
                           4'd3, 4'd0, 4'd0, 8'd3, 3'b000,
                           1, 0, 0, 0, 2'b10, 2'b00, 0, 0);

        // RET
        decode_instruction(16'b1010_0000_0000_0000,
                           4'd0, 4'd0, 4'd0, 8'd0, 3'b000,
                           0, 0, 0, 0, 2'b00, 2'b00, 0, 1);

        // CMP R3, R4
        decode_instruction(16'b0010_011_0100_0000,
                           4'd0, 4'd3, 4'd4, 8'd0, 3'b011,
                           0, 0, 0, 1, 2'b00, 2'b10, 0, 0);

        // BR Zero (Z)
        decode_instruction(16'b0001_010_0000_0000,
                           4'd0, 4'd0, 4'd0, 8'd0, 3'b010,
                           0, 0, 0, 0, 2'b00, 2'b00, 1, 0);

        #20;
        $display("Decoder testbench complete.");
        $finish;
    end

endmodule
