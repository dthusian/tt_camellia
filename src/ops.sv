`default_nettype none

module mux4(
  input wire a0,
  input wire a1,
  input wire a2,
  input wire a3,
  input wire s0,
  input wire s1,
  output wire q
);
  `ifdef SYNTHESIS
    sky130_fd_sc_hd__mux4_1 m(
      .X(q),
      .A0(a0),
      .A1(a1),
      .A2(a2),
      .A3(a3),
      .S0(s0),
      .S1(s1)
    );
  `else
    assign q =
      {s1, s0} == 'b00 ? a0 :
      {s1, s0} == 'b01 ? a1 :
      {s1, s0} == 'b10 ? a2 :
      a3;
  `endif
endmodule

module ops(
  input  wire        clk,

  // Control path
  input  wire [1:0]  subcycle,
  // 000 =  S1, 001 =  S2, 010 = FL1, 011 = FL2
  // 100 = XOR, 101 = XS1, 110 = XS2, 111 = XS3
  input  wire [2:0]  opcode,

  // Data path
  input  wire [31:0] data_a,
  input  wire [31:0] data_b,
  output var  [31:0] result
);
  // XOR-ing network
  logic [31:0] b_shift;
  logic [31:0] xored;
  generate
    for(genvar i = 0; i < 32; i++) begin
      mux4 m(
        .a0(data_b[i]),
        .a1(data_b[(i + 8) % 32]),
        .a2(data_b[(i + 16) % 32]),
        .a3(data_b[(i + 24) % 32]),
        .s0(opcode[0] & opcode[2]),
        .s1(opcode[1] & opcode[2]),
        .q(b_shift[i])
      );
    end
  endgenerate
  assign xored = b_shift ^ data_a;
  /*
  always_comb begin
    case(opcode)
      'b101: xored = data_a ^ {data_b[7:0], data_b[31:8]};
      'b110: xored = data_a ^ {data_b[15:0], data_b[31:16]};
      'b111: xored = data_a ^ {data_b[23:0], data_b[31:24]};
      default: xored = data_a ^ data_b;
    endcase
  end*/

  // S-boxes
  logic [1:0] sbox_ctl;
  logic [7:0] sbox_in;
  logic [7:0] sbox_shifted_in;
  logic [7:0] sbox_out;
  logic [7:0] sbox_shifted_out;
  logic [31:0] sbox_result;
  always_ff @(posedge clk) begin
    sbox_result[31:8] <= sbox_result[23:0];
  end
  always_comb begin
    sbox_ctl = subcycle + {1'b0, opcode[0]};
    // Input shift
    sbox_in = xored[{subcycle, 3'b000} +: 8];
    if(sbox_ctl == 'b00) begin
      sbox_shifted_in = {sbox_in[6:0], sbox_in[7]};
    end else begin
      sbox_shifted_in = sbox_in;
    end
    // Output shift
    if(sbox_ctl == 'b10) begin
      sbox_shifted_out = {sbox_out[6:0], sbox_out[7]};
    end else if(sbox_ctl == 'b01) begin
      sbox_shifted_out = {sbox_out[0], sbox_out[7:1]};
    end else begin
      sbox_shifted_out = sbox_out;
    end
    sbox_result[7:0] = sbox_shifted_out;
  end
  sbox i_sbox(
    .in(sbox_shifted_in),
    .out(sbox_out)
  );

  // FLA function
  logic [31:0] fla_unrot;
  logic [31:0] fla;
  assign fla_unrot = data_a & data_b;
  assign fla = {fla_unrot[30:0], fla_unrot[31]};

  // FLB function
  logic [31:0] flb;
  assign flb = data_a | data_b;

  // Output muxing
  always_comb begin
    case(opcode)
      'b000: result = sbox_result;
      'b001: result = sbox_result;
      'b010: result = fla;
      'b011: result = flb;
      default: result = xored;
    endcase
  end

endmodule
