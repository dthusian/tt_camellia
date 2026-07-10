`default_nettype none

module sbox_clmul(
  input  wire [3:0] in_a,
  input  wire [3:0] in_b,
  output wire [3:0] out
);
  logic [6:0] full_product;
  always_comb begin
    full_product = 0;
    if(in_b[0]) begin
      full_product = full_product ^ {3'b0, in_a};
    end
    if(in_b[1]) begin
      full_product = full_product ^ {2'b0, in_a, 1'b0};
    end
    if(in_b[2]) begin
      full_product = full_product ^ {1'b0, in_a, 2'b0};
    end
    if(in_b[3]) begin
      full_product = full_product ^ {in_a, 3'b0};
    end
  end

  assign out = full_product[3:0] ^ {1'b0, full_product[6:4]} ^ {full_product[6:4], 1'b0};
endmodule

module sbox_gf2_4_inv(
  input  wire [3:0] in,
  output var  [3:0] out
);
  always_comb begin
    case (in)
      'b0000: out = 'b0000;
      'b0001: out = 'b0001;
      'b0010: out = 'b1001;
      'b0011: out = 'b1110;
      'b0100: out = 'b1101;
      'b0101: out = 'b1011;
      'b0110: out = 'b0111;
      'b0111: out = 'b0110;
      'b1000: out = 'b1111;
      'b1001: out = 'b0010;
      'b1010: out = 'b1100;
      'b1011: out = 'b0101;
      'b1100: out = 'b1010;
      'b1101: out = 'b0100;
      'b1110: out = 'b0011;
      'b1111: out = 'b1000;
      default: out = 4'bxxxx;
    endcase
  end
endmodule

module sbox_g(
  input  wire [7:0] in,
  output wire [7:0] out
);
  logic [3:0] ph;
  assign ph = in[7:4];

  logic [3:0] pl;
  assign pl = in[3:0];

  logic [3:0] p16l;
  assign p16l = in[3:0] ^ in[7:4];

  logic [3:0] pl_p16l;
  sbox_clmul mul1(.in_a(pl), .in_b(p16l), .out(pl_p16l));

  logic [3:0] ph2;
  sbox_clmul mul2(.in_a(ph), .in_b(ph), .out(ph2));

  logic [3:0] ph2_w;
  sbox_clmul mul3(.in_a(ph2), .in_b(4'b1001), .out(ph2_w));

  logic [3:0] p17;
  assign p17 = ph2_w ^ pl_p16l;

  logic [3:0] pn17;
  sbox_gf2_4_inv inv(.in(p17), .out(pn17));

  logic [3:0] pnh;
  sbox_clmul mul4(.in_a(pn17), .in_b(ph), .out(pnh));

  logic [3:0] pnl;
  sbox_clmul mul5(.in_a(pn17), .in_b(p16l), .out(pnl));

  assign out = {pnh, pnl};
endmodule

module sbox (
  input  wire [7:0] in,
  output wire [7:0] out
);

  logic [7:0] f0;
  logic [7:0] f1;
  logic [7:0] f2;
  logic [7:0] h0;
  logic [7:0] h1;
  logic [7:0] h2;

  assign f0 = in;
  assign f1 = f0 ^ 'hc5;
  assign f2 = {
    f1[2] ^ f1[6],
    f1[1] ^ f1[7],
    f1[0] ^ f1[3] ^ f1[5],
    f1[0] ^ f1[5],
    f1[1] ^ f1[4],
    f1[3] ^ f1[6],
    f1[0] ^ f1[7],
    f1[2] ^ f1[4]
  };
  sbox_g g(.in(f2), .out(h0));
  assign h1 = {
    h0[3] ^ h0[2] ^ h0[6],
    h0[2] ^ h0[6],
    h0[1] ^ h0[4],
    h0[0] ^ h0[6],
    h0[1] ^ h0[5],
    h0[0] ^ h0[7],
    h0[3] ^ h0[7],
    h0[2] ^ h0[5]
  };
  assign h2 = h1 ^ 'h6e;
  assign out = h2;

endmodule
