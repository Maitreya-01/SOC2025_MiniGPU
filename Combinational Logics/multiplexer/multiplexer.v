module multiplexer (
						  input [3:0] in, 
						  input sel_a, 
						  input sel_b, 
						  output wire out);
		
		assign out = in[0]&(~sel_a)&(~sel_b) |
						 in[1]&(~sel_a)&sel_b |
						 in[2]&sel_a&(~sel_b)|
						 in[3]&sel_a&sel_b;
endmodule 