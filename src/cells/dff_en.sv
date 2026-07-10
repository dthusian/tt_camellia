
module dff_en #(
  parameter WIDTH = 1
) (
  input  wire             clk,
  input  wire [WIDTH-1:0] d,
  input  wire             de,
  output var  [WIDTH-1:0] q
);
`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < WIDTH; i++) begin : g
      sky130_fd_sc_hd__edfxtp_1 m(
        .Q(q[i]),
        .CLK(clk),
        .D(d[i]),
        .DE(de)
      );
    end
  endgenerate
`else
  always_ff @(posedge clk) begin
    if(de) begin
      q <= d;
    end
  end
`endif
endmodule
