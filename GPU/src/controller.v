module controller (
    input wire clk,
    input wire reset,

    // Consumer Interface (Fetchers / LSUs)
    input wire consumer_read_valid,
    input wire [7:0] consumer_read_address,
    output reg consumer_read_ready,
    output reg [15:0] consumer_read_data,
    input wire consumer_write_valid,
    input wire [7:0] consumer_write_address,
    input wire [15:0] consumer_write_data,
    output reg consumer_write_ready,

    // Memory Interface (Data / Program)
    output reg mem_read_valid,
    output reg [7:0] mem_read_address,
    input wire mem_read_ready,
    input wire [15:0] mem_read_data,
    output reg mem_write_valid,
    output reg [7:0] mem_write_address,
    output reg [15:0] mem_write_data,
    input wire mem_write_ready
);

    // Local parameters for state machine
    localparam IDLE = 3'b000;
    localparam READ_WAITING = 3'b010;
    localparam WRITE_WAITING = 3'b011;
    localparam READ_RELAYING = 3'b100;
    localparam WRITE_RELAYING = 3'b101;

    // State register
    reg [2:0] controller_state;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin 
            mem_read_valid <= 1'b0;
            mem_read_address <= 8'b0;
            mem_write_address <= 8'b0;
            mem_write_data <= 16'b0;
            mem_write_valid <= 1'b0;
            consumer_read_ready <= 1'b0;
            consumer_read_data <= 16'b0;
            consumer_write_ready <= 1'b0;
            controller_state <= IDLE;
        end else begin 
            case (controller_state)
                IDLE: begin
                    if (consumer_read_valid) begin 
                        mem_read_valid <= 1'b1;
                        mem_read_address <= consumer_read_address;
                        controller_state <= READ_WAITING;
                    end else if (consumer_write_valid) begin 
                        mem_write_valid <= 1'b1;
                        mem_write_address <= consumer_write_address;
                        mem_write_data <= consumer_write_data;
                        controller_state <= WRITE_WAITING;
                    end
                end
                
                READ_WAITING: begin
                    if (mem_read_ready) begin 
                        mem_read_valid <= 1'b0;
                        consumer_read_ready <= 1'b1;
                        consumer_read_data <= mem_read_data;
                        controller_state <= READ_RELAYING;
                    end
                end
                
                WRITE_WAITING: begin 
                    if (mem_write_ready) begin 
                        mem_write_valid <= 1'b0;
                        consumer_write_ready <= 1'b1;
                        controller_state <= WRITE_RELAYING;
                    end
                end
                
                READ_RELAYING: begin
                    if (!consumer_read_valid) begin 
                        consumer_read_ready <= 1'b0;
                        controller_state <= IDLE;
                    end
                end
                
                WRITE_RELAYING: begin 
                    if (!consumer_write_valid) begin 
                        consumer_write_ready <= 1'b0;
                        controller_state <= IDLE;
                    end
                end

                default: begin
                    controller_state <= IDLE;
                end
            endcase
        end
    end
endmodule