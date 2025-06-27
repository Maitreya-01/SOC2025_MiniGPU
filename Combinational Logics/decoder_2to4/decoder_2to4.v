module decoder_2to4 (
							input [1:0] code, 
							output reg [3:0] out);
	
	always @(*) begin
	 out = 4'b0000;
    if (code == 2'b00)
        assign out = 4'b0001;
    else if (code == 2'b01)
        assign out = 4'b0010;
    else if ( code == 2'b10)
        assign out = 4'b0100;
	 else if (code == 2'b11)
		  assign out = 4'b1000;
end
endmodule