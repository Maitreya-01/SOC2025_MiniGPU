module tb_decoder_2to4;
    reg [1:0] code;
    wire [3:0] out;

    decoder_2to4 uut (
        .code(code),
        .out(out)
    );

    initial begin
        $display("Time\tCode\tOut");
        $monitor("%0t\t%b\t%b", $time, code, out);

        code = 2'b00; #10;
        code = 2'b01; #10;
        code = 2'b10; #10;
        code = 2'b11; #10;

        $stop;
    end
endmodule