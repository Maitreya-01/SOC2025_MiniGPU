module lsu (
    input         clock,
    input         reset,
    input         enable,
    input         mem_read_enable,
    input         mem_write_enable,
    input         mem_read_ready,
    input         mem_write_ready,
    input  [2:0]  core_state,
    input  [7:0]  rs_out,
    input  [7:0]  rt_out,

    input  [7:0]  mem_read_data,

    output reg [7:0] mem_read_address,
    output reg [7:0] mem_write_address,
    output reg [7:0] mem_write_data,
    output reg [7:0] lsu_out,

    output reg [1:0] lsu_state
);

localparam IDLE       = 2'b00;
localparam REQUESTING = 2'b01;
localparam WAITING    = 2'b10;
localparam DONE       = 2'b11;

always @(posedge clock) begin
    if (reset) begin
        lsu_state         <= IDLE;
        lsu_out           <= 8'b00000000;
        mem_read_address  <= 8'b00000000;
        mem_write_address <= 8'b00000000;
        mem_write_data    <= 8'b00000000;
    end else if (enable) begin

        //Load instructions
        if (mem_read_enable) begin
            case (lsu_state)
                IDLE: begin
                    if (core_state == 3'b011) begin
                        lsu_state <= REQUESTING;
                    end
                end

                REQUESTING: begin
                    mem_read_address <= rs_out;
                    lsu_state        <= WAITING;
                end

                WAITING: begin
                    if (mem_read_ready) begin
                        lsu_out   <= mem_read_data;
                        lsu_state <= DONE;
                    end
                end

                DONE: begin
                    if (core_state == 3'b110) begin
                        lsu_state <= IDLE;
                    end
                end
            endcase
        end

        //store instructions
        if (mem_write_enable) begin
            case (lsu_state)
                IDLE: begin
                    if (core_state == 3'b011) begin
                        lsu_state <= REQUESTING;
                    end
                end

                REQUESTING: begin
                    mem_write_address <= rs_out;
                    mem_write_data    <= rt_out;
                    lsu_state         <= WAITING;
                end

                WAITING: begin
                    if (mem_write_ready) begin
                        lsu_state <= DONE;
                    end
                end

                DONE: begin
                    if (core_state == 3'b110) begin
                        lsu_state <= IDLE;
                    end
                end
            endcase
        end

    end
end

endmodule 