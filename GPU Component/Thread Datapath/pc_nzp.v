module pc_nzp (
    input        clock,
    input        reset,
    input        enable,
    input  [2:0] core_state,
    input        pc_out_mux,
    input  [2:0] nzp_instr,
    input  [2:0] nzp_out,
    input  [7:0] current_pc,
    input  [7:0] immediate,
    input        nzp_write_enable,
    
    output reg [2:0] nzp,
    output reg [7:0] next_pc
);

always @(posedge clock) begin
    if (reset) begin
        nzp     <= 3'b000;
        next_pc <= 8'b00000000;
    end else if (enable) begin
        if (core_state == 3'b101) begin
            if (pc_out_mux == 1'b1) begin
                if (nzp_instr == nzp) begin
                    next_pc <= immediate;
                end else begin
                    next_pc <= current_pc + 1;
                end
            end else begin
                next_pc <= current_pc + 1;
            end
        end

        if (core_state == 3'b110 && nzp_write_enable) begin
            nzp <= nzp_out;
        end
    end
end

endmodule 