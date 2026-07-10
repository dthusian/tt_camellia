`default_nettype none

// slang lint_off unused-port

// placeholder control module to ensure other logic is not optimized away
module control(
  input  wire clk,
  input  wire rst,
  input  wire test_mode,
  input  wire cmd_key,
  input  wire cmd_data,
  input  wire cmd_encrypt,
  input  wire cmd_decrypt,
  output var  [23:0] ctl
);

  always_ff @(posedge clk) begin
    ctl <= {ctl[22:0], test_mode};
  end
endmodule
