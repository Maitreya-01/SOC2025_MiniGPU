`timescale 1ns / 1ps

module top_tb;

  reg clock = 0;
  reg reset = 1;

  // Instantiate the top module
  top uut (
    .clock(clock),
    .reset(reset)
  );

  // Generate 10ns clock (100 MHz)
  always #5 clock = ~clock;

  initial begin
    $display("Starting simulation...");

    // Optional waveform dump (for ModelSim GUI)
    $dumpfile("top.vcd");
    $dumpvars(0, top_tb);

    // Reset pulse
    #10 reset = 1;
    #20 reset = 0;

    // Let system run
    #500;

    $display("Simulation complete.");
    $finish;
  end

endmodule
