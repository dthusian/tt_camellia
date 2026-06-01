`default_nettype none

// placeholder control module to ensure other logic is not optimized away
module placeholder_control(
  input  logic clk,
  input  logic in,
  output logic [63:0] ctl
);

  always_ff @(posedge clk) begin
    ctl <= {ctl[62:0], in};
  end

endmodule