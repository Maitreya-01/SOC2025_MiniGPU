module dispatch #(
    parameter NUM_CORES = 2,
    parameter THREADS_PER_BLOCK = 4
) (
    input wire clk,
    input wire reset,
    input wire start,

    input wire [7:0] thread_count,

    // Core States
    input wire [NUM_CORES-1:0] core_done,
    output reg [NUM_CORES-1:0] core_start,
    output reg [NUM_CORES-1:0] core_reset,
    output reg [(NUM_CORES * 8)-1:0] core_block_id,
    output reg [(NUM_CORES * 3)-1:0] core_thread_count,

    
    output reg done
);
    // Calculate the total number of blocks based on total threads & threads per block
    wire [7:0] total_blocks;
    assign total_blocks = (thread_count + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;

    // Keep track of how many blocks have been processed
    reg [7:0] blocks_dispatched;
    reg [7:0] blocks_done;
    reg start_execution;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 1'b0;
            blocks_dispatched <= 8'b0;
            blocks_done <= 8'b0;
            start_execution <= 1'b0;

            // Explicit assignments for reset state (NUM_CORES = 2)
            core_start[0] <= 1'b0;
            core_start[1] <= 1'b0;
            core_reset[0] <= 1'b1;
            core_reset[1] <= 1'b1;
            core_block_id[7:0] <= 8'b0;
            core_block_id[15:8] <= 8'b0;
            core_thread_count[2:0] <= THREADS_PER_BLOCK;
            core_thread_count[5:3] <= THREADS_PER_BLOCK;

        end else if (start) begin
            if (!start_execution) begin 
                start_execution <= 1'b1;
                // Explicit assignments for start of execution
                core_reset[0] <= 1'b1;
                core_reset[1] <= 1'b1;
            end

            if (blocks_done == total_blocks && total_blocks > 0) begin 
                done <= 1'b1;
            end

            // Logic for core 0
            if (core_reset[0]) begin 
                core_reset[0] <= 1'b0;
                if (blocks_dispatched < total_blocks) begin 
                    core_start[0] <= 1'b1;
                    core_block_id[7:0] <= blocks_dispatched;
                    if (blocks_dispatched == total_blocks - 1) begin
                        core_thread_count[2:0] <= thread_count - (blocks_dispatched * THREADS_PER_BLOCK);
                    end else begin
                        core_thread_count[2:0] <= THREADS_PER_BLOCK;
                    end
                    blocks_dispatched <= blocks_dispatched + 1;
                end
            end
            if (core_start[0] && core_done[0]) begin
                core_reset[0] <= 1'b1;
                core_start[0] <= 1'b0;
                blocks_done <= blocks_done + 1;
            end

            // Logic for core 1
            if (core_reset[1]) begin 
                core_reset[1] <= 1'b0;
                if (blocks_dispatched < total_blocks) begin 
                    core_start[1] <= 1'b1;
                    core_block_id[15:8] <= blocks_dispatched;
                    if (blocks_dispatched == total_blocks - 1) begin
                        core_thread_count[5:3] <= thread_count - (blocks_dispatched * THREADS_PER_BLOCK);
                    end else begin
                        core_thread_count[5:3] <= THREADS_PER_BLOCK;
                    end
                    blocks_dispatched <= blocks_dispatched + 1;
                end
            end
            if (core_start[1] && core_done[1]) begin
                core_reset[1] <= 1'b1;
                core_start[1] <= 1'b0;
                blocks_done <= blocks_done + 1;
            end
        end
    end
endmodule