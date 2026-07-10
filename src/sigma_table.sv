`default_nettype none

module sigma_table(
  input  wire [1:0]  addr,
  output var  [63:0] data 
);
  always_comb begin
    case (addr)
      'h0: data = 'hA09E667F3BCC908B;
      'h1: data = 'hB67AE8584CAA73B2;
      'h2: data = 'hC6EF372FE94F82BE;
      'h3: data = 'h54FF53A5F1D36F1C;
      default: data = 64'bx;
    endcase
  end
endmodule
