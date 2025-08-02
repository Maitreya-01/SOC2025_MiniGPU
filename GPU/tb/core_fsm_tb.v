`timescale 1ns / 1ps

module core_fsm_tb;

    reg clk, reset, start;
    reg [1:0] fetcher_state;
    reg decoded_ret;
    reg [7:0] lsu_state_all;
    reg mem_read_enable, mem_write_enable;
    reg [7:0] next_pc;

    wire [7:0] current_pc;
    wire [2:0] core_state;
    wire done;

    // Instantiate DUT
    core_fsm uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .fetcher_state(fetcher_state),
        .decoded_ret(decoded_ret),
        .lsu_state_all(lsu_state_all),
        .mem_read_enable(mem_read_enable),
        .mem_write_enable(mem_write_enable),
        .next_pc(next_pc),
        .current_pc(current_pc),
        .core_state(core_state),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("---- Starting core_fsm Testbench ----");

        // Init
        clk = 0;
        reset = 1;
        start = 0;
        fetcher_state = 2'b00;
        decoded_ret = 0;
        lsu_state_all = 8'b0;
        mem_read_enable = 0;
        mem_write_enable = 0;
        next_pc = 8'd5;

        #10 reset = 0;

        // Start core
        #10 start = 1;
        #10 start = 0;

        // FETCH
        #10 fetcher_state = 2'b10; // FETCH_COMPLETE

        // DECODE
        #10 fetcher_state = 2'b00;

        // REQUEST & WAIT
        #10 mem_read_enable = 1;
        lsu_state_all = 8'b11110000; // LSUs are waiting

        // EXECUTE (memory not yet ready)
        #10;
        lsu_state_all = 8'b00000000; // LSUs done

        // UPDATE
        #10 mem_read_enable = 0;

        // Simulate return instruction
        #10 decoded_ret = 1;

        #20;

        $display("Current PC: %d", current_pc);
        $display("Core State: %b", core_state);
        $display("Done Flag  : %b", done);

        if (done === 1'b1)
            $display("FSM reached DONE state successfully.");
        else
            $error("FSM did not reach DONE as expected.");

        $display("---- core_fsm Testbench Complete ----");
        $finish;
    end

endmodule
