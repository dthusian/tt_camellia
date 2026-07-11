module latch #(
  parameter WIDTH = 1
) (
  output var  [WIDTH-1:0] q,
  input  wire             en,
  input  wire [WIDTH-1:0] d
);
`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < WIDTH; i++) begin : g
      sky130_fd_sc_hd__dlxtp_1 mplatch(
        .Q(q[i]),
        .D(d[i]),
        .GATE(en)
      );
    end
  endgenerate
`else
  always_latch begin
    if(en) begin
      q = d;
    end
  end
`endif
endmodule
