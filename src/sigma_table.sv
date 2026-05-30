`default_nettype none

module sigma_table(
  input logic [5:0] addr,
  output logic [7:0] data 
);
  logic [63:0] sigma;
  always_comb begin
    case (addr[5:3])
      'h0: sigma = 'hA09E667F3BCC908B;
      'h1: sigma = 'hB67AE8584CAA73B2;
      'h2: sigma = 'hC6EF372FE94F82BE;
      'h3: sigma = 'h54FF53A5F1D36F1C;
      'h4: sigma = 'h10E527FADE682D1D;
      'h5: sigma = 'hB05688C2B3E6C1FD;
      default: sigma = 64'bx;
    endcase
    case (addr[2:0])
      'h0: data = sigma[7:0];
      'h1: data = sigma[15:8];
      'h2: data = sigma[23:16];
      'h3: data = sigma[31:24];
      'h4: data = sigma[39:32];
      'h5: data = sigma[47:40];
      'h6: data = sigma[55:48];
      'h7: data = sigma[63:56];
    endcase
  end
endmodule