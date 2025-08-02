module fetcher (
    input wire clk,
    input wire reset,
    input wire [7:0] current_pc, 
    input wire [2:0] core_state,
    input wire mem_read_ready,
    input wire [15:0] mem_read_data,

    output reg [15:0] instruction,
    output reg mem_read_valid,
    output reg [7:0] mem_read_address, 
    output reg [1:0] fetcher_state 
);

// State machine for the fetcher
localparam IDLE = 2'b00;
localparam FETCHING = 2'b01;
localparam FETCHED = 2'b10;

// Core states
localparam FETCH_STATE = 3'b001;
localparam DECODE_STATE = 3'b010;

// Main logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        fetcher_state <= IDLE;
        mem_read_valid <= 1'b0;
        mem_read_address <= 8'b0;
        instruction <= 16'b0;
    end else begin
        case (fetcher_state)
            IDLE: begin
                if (core_state == FETCH_STATE) begin
                    fetcher_state <= FETCHING;
                    mem_read_valid <= 1'b1;
                    mem_read_address <= current_pc;
                end
            end

            FETCHING: begin
                if (mem_read_ready) begin
                    fetcher_state <= FETCHED;
                    instruction <= mem_read_data;
                    mem_read_valid <= 1'b0;
                end
            end

            FETCHED: begin
                if (core_state == DECODE_STATE) begin
                    fetcher_state <= IDLE;
                end
            end
        endcase
    end
end

endmodule