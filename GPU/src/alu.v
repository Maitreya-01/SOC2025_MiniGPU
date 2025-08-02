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

reg signed [8:0] signed_result; // 9 bits for signed operation

always @(posedge clock) begin
    if (reset) begin
        alu_out <= 8'b00000000;
        alu_nzp <= 3'b000;
    end 
    else if (enable && core_state == 3'b101) begin
        // Perform ALU operation
        case (alu_select)
            2'b00: signed_result = $signed({1'b0, operand_1}) + $signed({1'b0, operand_2});
            2'b01: signed_result = $signed({1'b0, operand_1}) - $signed({1'b0, operand_2});
            2'b10: signed_result = $signed(operand_1) * $signed(operand_2);
				2'b11: signed_result = (operand_2 != 0) ? $signed(operand_1) / $signed(operand_2) : 9'd0;
            default: signed_result = 9'd0;
        endcase

        // Output result
        alu_out <= signed_result[7:0];

        // Set NZP flag
        if (signed_result == 0)
            alu_nzp <= 3'b010; // Zero
        else if (signed_result[8] == 1'b1)
            alu_nzp <= 3'b001; // Negative
        else
            alu_nzp <= 3'b100; // Positive
    end
end

endmodule
