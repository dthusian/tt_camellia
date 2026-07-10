`default_nettype none

module sigma_table(
  input  wire [2:0]  addr,
  output var  [31:0] data 
);
  always_comb begin
    case (addr)
      'h0: data = 'hA09E667F;
      'h1: data = 'h3BCC908B;
      'h2: data = 'hB67AE858;
      'h3: data = 'h4CAA73B2;
      'h4: data = 'hC6EF372F;
      'h5: data = 'hE94F82BE;
      'h6: data = 'h54FF53A5;
      'h7: data = 'hF1D36F1C;
      default: data = 32'bx;
    endcase
  end
endmodule
