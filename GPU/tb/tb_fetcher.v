`timescale 1ns / 1ps

module tb_fetcher;

    // Inputs
    reg clk;
    reg reset;
    reg [7:0] current_pc;
    reg [2:0] core_state;
    reg mem_read_ready;
    reg [15:0] mem_read_data;

    // Outputs
    wire [15:0] instruction;
    wire mem_read_valid;
    wire [7:0] mem_read_address;
    wire [1:0] fetcher_state;

    // Instantiate the fetcher module
    fetcher uut (
        .clk(clk),
        .reset(reset),
        .current_pc(current_pc),
        .core_state(core_state),
        .mem_read_ready(mem_read_ready),
        .mem_read_data(mem_read_data),
        .instruction(instruction),
        .mem_read_valid(mem_read_valid),
        .mem_read_address(mem_read_address),
        .fetcher_state(fetcher_state)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("---- Starting Fetcher Testbench ----");
        $dumpfile("tb_fetcher.vcd");
        $dumpvars(0, tb_fetcher);

        // Initialize inputs
        reset = 1;
        core_state = 3'b000;
        current_pc = 8'd10;
        mem_read_ready = 0;
        mem_read_data = 16'hABCD;

        #12 reset = 0;

        // === Test 1: mem_read_valid and address ===
        #10 core_state = 3'b001; // FETCH_STATE
        #1;
        if (mem_read_valid && mem_read_address == current_pc)
            $display("Test 1 (mem_read_valid & addr): PASSED");
        else
            $error("Test 1 (mem_read_valid & addr): FAILED — valid: %b, addr: %h (expected %h)",
                    mem_read_valid, mem_read_address, current_pc);

        // === Test 2: instruction = mem_read_data when ready ===
        #9;
        core_state = 3'b001;
        mem_read_ready = 1;
        #10;
        mem_read_ready = 0;

        #2;
        if (instruction == mem_read_data)
            $display("Test 2 (instruction capture): PASSED");
        else
            $error("Test 2 (instruction capture): FAILED — Expected %h, got %h", mem_read_data, instruction);

        // === Test 3: fetcher_state after decode ===
        core_state = 3'b010; // DECODE_STATE
        #10;
        if (fetcher_state == 2'b00)  // Assuming it resets to IDLE or FETCH
            $display("Test 3 (fetcher_state reset): PASSED");
        else
            $error("Test 3 (fetcher_state reset): FAILED — Got state: %b", fetcher_state);

        $display("---- Fetcher Testbench Complete ----");
        $finish;
    end

endmodule
