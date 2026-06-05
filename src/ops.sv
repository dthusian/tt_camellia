`default_nettype none
module ops(
  input  logic        clk,

  // Control path
  input  logic        wordsel, // Only valid for F. 0 = Low-half 1 = High-half
  input  logic [1:0]  opcode, // 00 = F, 01 = xor, 10 = FL, 11 = FLINV

  // Data path
  input  logic [31:0] key,
  input  logic [31:0] data,
  output logic [31:0] result
);
  logic [31:0] xored;
  assign xored = key ^ data;

  logic [31:0] pre_sbox;
  logic [31:0] post_sbox;
  assign pre_sbox = wordsel ? xored : {xored[7:0], xored[31:8]};
  sbox s1(
    .in(pre_sbox[31:24]),
    .out(post_sbox[31:24])
  );
  sbox s2(
    .in(pre_sbox[23:16]),
    .out(post_sbox[23:16])
  );
  sbox s3(
    .in(pre_sbox[15:8]),
    .out(post_sbox[15:8])
  );
  sbox s4(
    .in(pre_sbox[7:0]),
    .out(post_sbox[7:0])
  );

  logic [31:0] scratch;
  always_ff @(posedge clk) begin
    if(wordsel) begin
      scratch <= post_sbox;
    end
  end

  logic [63:0] p0;
  logic [63:0] p1;
  logic [63:0] p2;
  logic [63:0] p3;
  always_comb begin
    p0 = {scratch, post_sbox[23:0], post_sbox[31:24]};
    p1[63:32] = p0[63:32] ^ {p0[23:0], p0[31:24]};
    p1[31:0] = p0[31:0] ^ {p0[47:32], p0[63:48]};
    p2[63:32] = p1[63:32] ^ {p1[7:0], p1[31:8]};
    p2[31:0] = p1[31:0] ^ {p1[39:32], p1[63:40]};
    p3[63:32] = p2[31:0];
    p3[31:0] = p2[63:32];
  end
  
  always_comb begin
    case(opcode)
      'b00: result = wordsel ? p3[63:32] : p3[31:0]; // todo
      'b01: result = xored;
      'b10: result = 'b0; // todo
      'b11: result = 'b0; // todo
    endcase
  end
endmodule