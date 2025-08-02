module core_fsm (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [1:0] fetcher_state,
    input wire decoded_ret,
    input wire [7:0] lsu_state_all, 
    input wire mem_read_enable, 
    input wire mem_write_enable,
    input wire [7:0] next_pc, 
    output reg [7:0] current_pc, 
    output reg [2:0] core_state,
    output reg done
);

    // States for the core FSM
    localparam IDLE      = 3'b000;
    localparam FETCH     = 3'b001;
    localparam DECODE    = 3'b010;
    localparam REQUEST   = 3'b011;
    localparam WAIT      = 3'b100;
    localparam EXECUTE   = 3'b101;
    localparam UPDATE    = 3'b110;
    localparam DONE_STATE  = 3'b111;

    // The 'always' block describes the state transitions
    reg any_lsu_waiting;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_pc <= 8'b0; // Reset PC to 0
            core_state <= IDLE;
            done <= 1'b0;
        end else begin
            case (core_state)
                IDLE: begin
                    if (start) begin
                        core_state <= FETCH;
                    end
                end

                FETCH: begin
                    if (fetcher_state == 2'b10) begin 
                        core_state <= DECODE;
                    end
                end

                DECODE: begin
                    
                    core_state <= REQUEST;
                end

                REQUEST: begin
                    
                    if (mem_read_enable || mem_write_enable) begin
                        core_state <= WAIT;
                    end else begin
                        core_state <= EXECUTE;
                    end
                end

                WAIT: begin
                    // Check all 4 LSU states to see if any are in REQUESTING (2'b01) or WAITING (2'b10)
                    any_lsu_waiting = (lsu_state_all[1:0] == 2'b01 || lsu_state_all[1:0] == 2'b10) || // LSU 0
                                      (lsu_state_all[3:2] == 2'b01 || lsu_state_all[3:2] == 2'b10) || // LSU 1
                                      (lsu_state_all[5:4] == 2'b01 || lsu_state_all[5:4] == 2'b10) || // LSU 2
                                      (lsu_state_all[7:6] == 2'b01 || lsu_state_all[7:6] == 2'b10);    // LSU 3

                    if (!any_lsu_waiting) begin
                        core_state <= EXECUTE;
                    end
                end

                EXECUTE: begin
                    core_state <= UPDATE;
                end

                UPDATE: begin
                    if (decoded_ret) begin
                        done <= 1'b1;
                        core_state <= DONE_STATE;
                    end else begin
                        current_pc <= next_pc; 
                        core_state <= FETCH;
                    end
                end

                DONE_STATE: begin
                    // No operation, waiting for reset
                end
                
                default: begin
                    
                    core_state <= IDLE;
                end
            endcase
        end
    end
endmodule