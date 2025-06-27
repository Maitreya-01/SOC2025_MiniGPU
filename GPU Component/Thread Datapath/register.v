module register (
    input         clock,
    input         reset,
    input         enable,
    input         reg_write_enable,
    input  [2:0]  core_state,
    input  [3:0]  rs_address,
    input  [3:0]  rt_address,
    input  [3:0]  rd_address,
    input  [1:0]  reg_input_mux,
    input  [7:0]  alu_out,
    input  [7:0]  lsu_out,
    input  [7:0]  immediate,
    input  [7:0]  block_id,
    output [7:0]  rs_data,
    output [7:0]  rt_data
);

reg [7:0] registers [0:15];

assign rs_data = registers[rs_address];
assign rt_data = registers[rt_address];

integer i;
always @(posedge clock) begin
    if (reset) begin
        for (i = 0; i <= 12; i = i + 1)
            registers[i] <= 8'b00000000;

        registers[13] <= 8'b00000000;
        registers[14] <= 8'b00000100;
        registers[15] <= 8'b00000000;
    end
    else if (enable) begin
        if (reg_write_enable) begin
            registers[13] <= block_id;

            if (core_state == 3'b110 && rd_address < 13) begin
                case (reg_input_mux)
                    2'b00: registers[rd_address] <= alu_out;
                    2'b01: registers[rd_address] <= lsu_out;
                    2'b10: registers[rd_address] <= immediate;
                    default: registers[rd_address] <= 8'b00000000;
                endcase
            end
        end
    end
end

endmodule
