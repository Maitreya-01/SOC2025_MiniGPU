module dcr (
    input wire clk,
    input wire reset,

    input wire device_control_write_enable,
    input wire [7:0] device_control_data,
    output wire [7:0] thread_count
);
    // Store device control data in dedicated register
    reg [7:0] device_conrol_register;
    assign thread_count = device_conrol_register;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            device_conrol_register <= 8'b0;
        end else begin
            if (device_control_write_enable) begin 
                device_conrol_register <= device_control_data;
            end
        end
    end
endmodule