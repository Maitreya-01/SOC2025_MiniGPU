module decoder (
    input wire clk,
    input wire reset,
    input wire [15:0] instruction,
    input wire [2:0] core_state,

    output reg [3:0] rd_address,
    output reg [3:0] rs_address,
    output reg [3:0] rt_address,
    output reg [7:0] immediate,
    output reg [2:0] nzp_instr,

    output reg reg_write_enable,
    output reg mem_read_enable,
    output reg mem_write_enable,
    output reg nzp_write_enable,

    output reg [1:0] reg_input_mux,
    output reg [1:0] alu_select,
    output reg pc_out_mux,
    output reg decoded_ret
);

// Define core states
localparam DECODE_STATE = 3'b010;

localparam NOP_OPCODE   = 4'b0000;
localparam BR_OPCODE    = 4'b0001;
localparam CMP_OPCODE   = 4'b0010;
localparam ADD_OPCODE   = 4'b0011;
localparam SUB_OPCODE   = 4'b0100;
localparam MUL_OPCODE   = 4'b0101;
localparam DIV_OPCODE   = 4'b0110;
localparam LDR_OPCODE   = 4'b0111;
localparam STR_OPCODE   = 4'b1000;
localparam CONST_OPCODE = 4'b1001;
localparam RET_OPCODE   = 4'b1010;

// This always block handles the state transitions and output signal generation.
always @(posedge clk or posedge reset) begin
    if (reset) begin
        rd_address <= 4'b0;
        rs_address <= 4'b0;
        rt_address <= 4'b0;
        immediate <= 8'b0;
        nzp_instr <= 3'b0;
        reg_write_enable <= 1'b0;
        mem_read_enable <= 1'b0;
        mem_write_enable <= 1'b0;
        nzp_write_enable <= 1'b0;
        reg_input_mux <= 2'b0;
        alu_select <= 2'b0;
        pc_out_mux <= 1'b0;
        decoded_ret <= 1'b0;
    end else if (core_state == DECODE_STATE) begin

        rd_address <= instruction[11:8];
        rs_address <= instruction[7:4];
        rt_address <= instruction[3:0];
        immediate <= instruction[7:0];
        nzp_instr <= instruction[11:9];

        reg_write_enable <= 1'b0;
        mem_read_enable <= 1'b0;
        mem_write_enable <= 1'b0;
        nzp_write_enable <= 1'b0;
        reg_input_mux <= 2'b0;
        alu_select <= 2'b0;
        pc_out_mux <= 1'b0;
        decoded_ret <= 1'b0;

        case (instruction[15:12])
            BR_OPCODE: begin
                pc_out_mux <= 1'b1;
            end
            CMP_OPCODE: begin
                nzp_write_enable <= 1'b1;
            end
            ADD_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b00; // Select ALU output
                alu_select <= 2'b00; // Select ADD operation
            end
            SUB_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b00; // Select ALU output
                alu_select <= 2'b01; // Select SUB operation
            end
            MUL_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b00; // Select ALU output
                alu_select <= 2'b10; // Select MUL operation
            end
            DIV_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b00; // Select ALU output
                alu_select <= 2'b11; // Select DIV operation
            end
            LDR_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b01; // Select memory data
                mem_read_enable <= 1'b1;
            end
            STR_OPCODE: begin
                mem_write_enable <= 1'b1;
            end
            CONST_OPCODE: begin
                reg_write_enable <= 1'b1;
                reg_input_mux <= 2'b10; // Select immediate value
            end
            RET_OPCODE: begin
                decoded_ret <= 1'b1;
            end
            default: begin
            end
        endcase
    end
end

endmodule