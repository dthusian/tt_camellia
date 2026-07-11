`default_nettype none

module mux4 #(
  parameter WIDTH = 1
) (
  input  wire [WIDTH-1:0] a0,
  input  wire [WIDTH-1:0] a1,
  input  wire [WIDTH-1:0] a2,
  input  wire [WIDTH-1:0] a3,

  input  wire             s0,
  input  wire             s1,
  output var  [WIDTH-1:0] x
);
`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < WIDTH; i++) begin : g
      sky130_fd_sc_hd__mux4_1 m(
        .X(x[i]),
        .A0(a0[i]),
        .A1(a1[i]),
        .A2(a2[i]),
        .A3(a3[i]),
        .S0(s0),
        .S1(s1)
      );
    end
  endgenerate
`else
  always_comb begin
    case({s1, s0})
      'b00: x = a0;
      'b01: x = a1;
      'b10: x = a2;
      'b11: x = a3;
      default: x = {WIDTH{1'bx}}; // unreachable
    endcase
  end
`endif
endmodule
