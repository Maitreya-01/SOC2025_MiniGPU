module alu (
    input        clock,
    input        reset,
    input        enable,
    input  [2:0] core_state,
    input  [1:0] alu_select,
    input  [7:0] operand_1,
    input  [7:0] operand_2,
    output reg [7:0] alu_out,
    output reg [2:0] alu_nzp
);

always @(posedge clock) begin
    if (reset) begin
        alu_out <= 8'b00000000;
        alu_nzp <= 3'b000;
    end 
    else if (enable && core_state == 3'b101) begin
        case (alu_select)
            2'b00: alu_out <= operand_1 + operand_2;
            2'b01: alu_out <= operand_1 - operand_2;
            2'b10: alu_out <= operand_1 & operand_2;
            2'b11: alu_out <= operand_1 ^ operand_2;
            default: alu_out <= 8'b00000000;
        endcase

        if ($signed(alu_out) > 0)
            alu_nzp <= 3'b001;  // Positive
        else if (alu_out == 0)
            alu_nzp <= 3'b010;  // Zero
        else
            alu_nzp <= 3'b100;  // Negative
    end
end

endmodule 