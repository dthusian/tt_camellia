`default_nettype none

module mux2 #(
  parameter WIDTH = 1
) (
  input  wire [WIDTH-1:0] a0,
  input  wire [WIDTH-1:0] a1,

  input  wire             s0,
  output wire [WIDTH-1:0] x
);
`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < WIDTH; i++) begin : g
      sky130_fd_sc_hd__mux2_1 m(
        .X(x[i]),
        .A0(a0[i]),
        .A1(a1[i]),
        .S(s0)
      );
    end
  endgenerate
`else
  assign x = s0 ? a1 : a0;
`endif
endmodule
