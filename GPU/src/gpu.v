module gpu #(
    parameter DATA_MEM_ADDR_BITS = 8,
    parameter DATA_MEM_DATA_BITS = 8,
    parameter DATA_MEM_NUM_CHANNELS = 4,
    parameter PROGRAM_MEM_ADDR_BITS = 8,
    parameter PROGRAM_MEM_DATA_BITS = 16,
    parameter PROGRAM_MEM_NUM_CHANNELS = 1,
    parameter NUM_CORES = 2,
    parameter THREADS_PER_BLOCK = 4
) (
    input wire clk,
    input wire reset,
    input wire start,
    output wire done,

    input wire device_control_write_enable,
    input wire [7:0] device_control_data,

    output wire [PROGRAM_MEM_NUM_CHANNELS-1:0] program_mem_read_valid,
    output wire [PROGRAM_MEM_ADDR_BITS-1:0] program_mem_read_address,
    input wire [PROGRAM_MEM_NUM_CHANNELS-1:0] program_mem_read_ready,
    input wire [PROGRAM_MEM_DATA_BITS-1:0] program_mem_read_data,

    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_valid,
    output wire [DATA_MEM_ADDR_BITS-1:0] data_mem_read_address,
    input wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_read_ready,
    input wire [DATA_MEM_DATA_BITS-1:0] data_mem_read_data,
    output wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_valid,
    output wire [DATA_MEM_ADDR_BITS-1:0] data_mem_write_address,
    output wire [DATA_MEM_DATA_BITS-1:0] data_mem_write_data,
    input wire [DATA_MEM_NUM_CHANNELS-1:0] data_mem_write_ready
);
    
    // Control
    wire [7:0] thread_count;

    // Compute Core State
    wire [NUM_CORES-1:0] core_start;
    wire [NUM_CORES-1:0] core_reset;
    wire [NUM_CORES-1:0] core_done;
    wire [(NUM_CORES * 8)-1:0] core_block_id_vec;
    wire [(NUM_CORES * 3)-1:0] core_thread_count_vec;

    // LSU <> Data Memory Controller Channels (arrays converted to vectors)
    localparam NUM_LSUS = NUM_CORES * THREADS_PER_BLOCK;
    wire [NUM_LSUS-1:0] lsu_read_valid;
    wire [(NUM_LSUS * DATA_MEM_ADDR_BITS)-1:0] lsu_read_address_vec;
    wire [NUM_LSUS-1:0] lsu_read_ready;
    wire [(NUM_LSUS * DATA_MEM_DATA_BITS)-1:0] lsu_read_data_vec;
    wire [NUM_LSUS-1:0] lsu_write_valid;
    wire [(NUM_LSUS * DATA_MEM_ADDR_BITS)-1:0] lsu_write_address_vec;
    wire [(NUM_LSUS * DATA_MEM_DATA_BITS)-1:0] lsu_write_data_vec;
    wire [NUM_LSUS-1:0] lsu_write_ready;

    // Fetcher <> Program Memory Controller Channels (arrays converted to vectors)
    localparam NUM_FETCHERS = NUM_CORES;
    reg [NUM_FETCHERS-1:0] fetcher_read_valid;
    reg [(NUM_FETCHERS * PROGRAM_MEM_ADDR_BITS)-1:0] fetcher_read_address_vec;
    wire [NUM_FETCHERS-1:0] fetcher_read_ready;
    wire [(NUM_FETCHERS * PROGRAM_MEM_DATA_BITS)-1:0] fetcher_read_data_vec;
    
    // Generate block variables
    genvar i;
    genvar j;
    
    // Device Control Register
    dcr dcr_instance (
        .clk(clk),
        .reset(reset),
        .device_control_write_enable(device_control_write_enable),
        .device_control_data(device_control_data),
        .thread_count(thread_count)
    );

    // Data Memory Controller
    controller data_memory_controller (
        .clk(clk),
        .reset(reset),
        .consumer_read_valid(lsu_read_valid),
        .consumer_read_address(lsu_read_address_vec),
        .consumer_read_ready(lsu_read_ready),
        .consumer_read_data(lsu_read_data_vec),
        .consumer_write_valid(lsu_write_valid),
        .consumer_write_address(lsu_write_address_vec),
        .consumer_write_data(lsu_write_data_vec),
        .consumer_write_ready(lsu_write_ready),
        .mem_read_valid(data_mem_read_valid),
        .mem_read_address(data_mem_read_address),
        .mem_read_ready(data_mem_read_ready),
        .mem_read_data(data_mem_read_data),
        .mem_write_valid(data_mem_write_valid),
        .mem_write_address(data_mem_write_address),
        .mem_write_data(data_mem_write_data),
        .mem_write_ready(data_mem_write_ready)
    );

    // Program Memory Controller
    controller program_memory_controller (
        .clk(clk),
        .reset(reset),
        .consumer_read_valid(fetcher_read_valid),
        .consumer_read_address(fetcher_read_address_vec),
        .consumer_read_ready(fetcher_read_ready),
        .consumer_read_data(fetcher_read_data_vec),
        .mem_read_valid(program_mem_read_valid),
        .mem_read_address(program_mem_read_address),
        .mem_read_ready(program_mem_read_ready),
        .mem_read_data(program_mem_read_data)
    );

    // Dispatcher
    dispatch #(
        .NUM_CORES(NUM_CORES),
        .THREADS_PER_BLOCK(THREADS_PER_BLOCK)
    ) dispatch_instance (
        .clk(clk),
        .reset(reset),
        .start(start),
        .thread_count(thread_count),
        .core_done(core_done),
        .core_start(core_start),
        .core_reset(core_reset),
        .core_block_id(core_block_id_vec), // Corrected port name
        .core_thread_count(core_thread_count_vec), // Corrected port name
        .done(done)
    );

    // Compute Cores
    generate
        for (i = 0; i < NUM_CORES; i = i + 1) begin: cores
            wire [THREADS_PER_BLOCK-1:0] core_lsu_read_valid;
            wire [(THREADS_PER_BLOCK * DATA_MEM_ADDR_BITS)-1:0] core_lsu_read_address_vec;
            wire [THREADS_PER_BLOCK-1:0] core_lsu_read_ready;
            wire [(THREADS_PER_BLOCK * DATA_MEM_DATA_BITS)-1:0] core_lsu_read_data_vec;
            wire [THREADS_PER_BLOCK-1:0] core_lsu_write_valid;
            wire [(THREADS_PER_BLOCK * DATA_MEM_ADDR_BITS)-1:0] core_lsu_write_address_vec;
            wire [(THREADS_PER_BLOCK * DATA_MEM_DATA_BITS)-1:0] core_lsu_write_data_vec;
            wire [THREADS_PER_BLOCK-1:0] core_lsu_write_ready;
            
            for (j = 0; j < THREADS_PER_BLOCK; j = j + 1) begin: lsu_connections
                localparam lsu_index = i * THREADS_PER_BLOCK + j;

                // Connections from core to data memory controller
                assign lsu_read_valid[lsu_index] = core_lsu_read_valid[j];
                assign lsu_read_address_vec[(lsu_index*DATA_MEM_ADDR_BITS)+(DATA_MEM_ADDR_BITS-1) : lsu_index*DATA_MEM_ADDR_BITS] = core_lsu_read_address_vec[(j*DATA_MEM_ADDR_BITS)+(DATA_MEM_ADDR_BITS-1) : j*DATA_MEM_ADDR_BITS];
                assign lsu_write_valid[lsu_index] = core_lsu_write_valid[j];
                assign lsu_write_address_vec[(lsu_index*DATA_MEM_ADDR_BITS)+(DATA_MEM_ADDR_BITS-1) : lsu_index*DATA_MEM_ADDR_BITS] = core_lsu_write_address_vec[(j*DATA_MEM_ADDR_BITS)+(DATA_MEM_ADDR_BITS-1) : j*DATA_MEM_ADDR_BITS];
                assign lsu_write_data_vec[(lsu_index*DATA_MEM_DATA_BITS)+(DATA_MEM_DATA_BITS-1) : lsu_index*DATA_MEM_DATA_BITS] = core_lsu_write_data_vec[(j*DATA_MEM_DATA_BITS)+(DATA_MEM_DATA_BITS-1) : j*DATA_MEM_DATA_BITS];

                // Connections from data memory controller to core
                assign core_lsu_read_ready[j] = lsu_read_ready[lsu_index];
                assign core_lsu_read_data_vec[(j*DATA_MEM_DATA_BITS)+(DATA_MEM_DATA_BITS-1) : j*DATA_MEM_DATA_BITS] = lsu_read_data_vec[(lsu_index*DATA_MEM_DATA_BITS)+(DATA_MEM_DATA_BITS-1) : lsu_index*DATA_MEM_DATA_BITS];
                assign core_lsu_write_ready[j] = lsu_write_ready[lsu_index];
            end
            
            miniGPU_core core_instance (
                .clk(clk),
                .reset(core_reset[i]),
                .start(core_start[i]),
                .done(core_done[i]),
                .block_id(core_block_id_vec[(i*8)+7 : i*8]),
                .thread_count(core_thread_count_vec[(i*3)+2 : i*3]),
                .program_mem_read_valid(fetcher_read_valid[i]),
                .program_mem_read_address(fetcher_read_address_vec[(i*8)+7 : i*8]),
                .program_mem_read_ready(fetcher_read_ready[i]),
                .program_mem_read_data(fetcher_read_data_vec[(i*16)+15 : i*16]),
                .data_mem_read_valid(core_lsu_read_valid),
                .data_mem_read_address(core_lsu_read_address_vec),
                .data_mem_read_ready(core_lsu_read_ready),
                .data_mem_read_data(core_lsu_read_data_vec),
                .data_mem_write_valid(core_lsu_write_valid),
                .data_mem_write_address(core_lsu_write_address_vec),
                .data_mem_write_data(core_lsu_write_data_vec),
                .data_mem_write_ready(core_lsu_write_ready)
            );
        end
    endgenerate
endmodule