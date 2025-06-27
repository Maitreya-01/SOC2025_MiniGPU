module tb_multiplexer;
    reg [3:0] in;
    reg sel_a, sel_b;
    wire out;

    multiplexer uut (
        .in(in),
        .sel_a(sel_a),
        .sel_b(sel_b),
        .out(out)
    );

    initial begin
        $display("Time\tSel_a Sel_b\tIn\tOut");
        $monitor("%0t\t%b\t%b\t%b\t%b", $time, sel_a, sel_b, in, out);

        in = 4'b0001; sel_a = 0; sel_b = 0; #10; 
        in = 4'b0010; sel_a = 0; sel_b = 1; #10; 
        in = 4'b0100; sel_a = 1; sel_b = 0; #10; 
        in = 4'b1000; sel_a = 1; sel_b = 1; #10; 

        in = 4'b1110; sel_a = 0; sel_b = 0; #10;
        in = 4'b1101; sel_a = 0; sel_b = 1; #10;
        in = 4'b1011; sel_a = 1; sel_b = 0; #10;
        in = 4'b0111; sel_a = 1; sel_b = 1; #10;
		  
		  in = 4'b1111; sel_a = 0; sel_b = 0; #10;
        in = 4'b1111; sel_a = 0; sel_b = 1; #10;
        in = 4'b1111; sel_a = 1; sel_b = 0; #10;
        in = 4'b1111; sel_a = 1; sel_b = 1; #10;


        $stop;
    end
endmodule
