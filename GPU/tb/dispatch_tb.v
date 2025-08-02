`timescale 1ns / 1ps

module dispatch_tb;

    reg clk, reset, start;
    reg [7:0] thread_count;
    reg [1:0] core_done;
    wire [1:0] core_start, core_reset;
    wire [15:0] core_block_id;
    wire [5:0] core_thread_count;
    wire done;

    // Parameter
    parameter THREADS_PER_BLOCK = 4;
    parameter NUM_CORES = 2;

    dispatch #(.NUM_CORES(NUM_CORES), .THREADS_PER_BLOCK(THREADS_PER_BLOCK)) uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .thread_count(thread_count),
        .core_done(core_done),
        .core_start(core_start),
        .core_reset(core_reset),
        .core_block_id(core_block_id),
        .core_thread_count(core_thread_count),
        .done(done)
    );

    integer i;
    integer blocks_dispatched;
    integer expected_blocks;

    always #5 clk = ~clk;

    initial begin
        $display("---- Starting Dispatch Testbench ----");

        // Initialization
        clk = 0;
        reset = 1;
        start = 0;
        core_done = 2'b00;
        thread_count = 8'd10;
        blocks_dispatched = 0;
        expected_blocks = (thread_count + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;

        #20 reset = 0;

        // Trigger dispatch
        start = 1;
        #10 start = 0;
    end

    always @(posedge clk) begin
        for (i = 0; i < NUM_CORES; i = i + 1) begin
            if (core_start[i]) begin
                blocks_dispatched = blocks_dispatched + 1;
                $display("Dispatched block %0d to core %0d, thread count = %0d",
                          blocks_dispatched, i, core_thread_count);
                if (core_thread_count > THREADS_PER_BLOCK) begin
                    $display("ERROR: Thread count per block exceeds max: %0d", core_thread_count);
                end
            end
        end
    end

    initial begin
        wait(core_start[0]); #10 core_done[0] = 1; #10 core_done[0] = 0;
        wait(core_start[1]); #10 core_done[1] = 1; #10 core_done[1] = 0;
        wait(core_start[0]); #10 core_done[0] = 1; #10 core_done[0] = 0;
    end

    initial begin
        wait(done);
        $display("Dispatch module signaled done.");
        if (blocks_dispatched != expected_blocks)
            $display("ERROR: Dispatch count mismatch: expected %0d, got %0d",
                      expected_blocks, blocks_dispatched);
        else
            $display("SUCCESS: All %0d blocks dispatched and completed correctly.", blocks_dispatched);

        $display("---- Dispatch Testbench Complete ----");
        $finish;
    end

endmodule
