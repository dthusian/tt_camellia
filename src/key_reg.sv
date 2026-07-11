`default_nettype none

module key_reg(
  input  wire [7:0]  latch_en,
  input  wire [31:0] latch_in,

  input  wire        key_idx,
  input  wire [1:0]  word_idx,
  input  wire [2:0]  shift_idx,

  output wire [31:0] key_out
);
  // Key latches
  logic [255:0] keys;
  logic [1:0] read_addr1;
  logic [1:0] read_addr2;
  logic [2:0] read_addr3;
  logic [15:0] read_data1;
  logic [15:0] read_data2;
  logic [3:0] read_data3;

  generate
    for(genvar i = 0; i < 8; i++) begin : g
      latch #(.WIDTH(32)) key_latch(
        .q(keys[i*32 +: 32]),
        .en(latch_en[i]),
        .d(latch_in)
      );
    end
  endgenerate

  // Read muxes 1,2
  logic [15:0] mux1 [1:0];
  logic [15:0] mux2 [1:0];
  mux4 #(.WIDTH(16)) mpmux1 (
    .x(mux1[0]),
    .a0(keys[0*16 +: 16]),
    .a1(keys[2*16 +: 16]),
    .a2(keys[4*16 +: 16]),
    .a3(keys[6*16 +: 16]),
    .s0(read_addr1[0]),
    .s1(read_addr1[1])
  );
  mux4 #(.WIDTH(16)) mpmux2 (
    .x(mux1[1]),
    .a0(keys[8*16  +: 16]),
    .a1(keys[10*16 +: 16]),
    .a2(keys[12*16 +: 16]),
    .a3(keys[14*16 +: 16]),
    .s0(read_addr1[0]),
    .s1(read_addr1[1])
  );
  mux4 #(.WIDTH(16)) mpmux3 (
    .x(mux2[0]),
    .a0(keys[1*16 +: 16]),
    .a1(keys[3*16 +: 16]),
    .a2(keys[5*16 +: 16]),
    .a3(keys[7*16 +: 16]),
    .s0(read_addr2[0]),
    .s1(read_addr2[1])
  );
  mux4 #(.WIDTH(16)) mpmux4 (
    .x(mux2[1]),
    .a0(keys[9*16  +: 16]),
    .a1(keys[11*16 +: 16]),
    .a2(keys[13*16 +: 16]),
    .a3(keys[15*16 +: 16]),
    .s0(read_addr2[0]),
    .s1(read_addr2[1])
  );
  mux2 #(.WIDTH(16)) mpmux5 (
    .x(read_data1),
    .a0(mux1[0]),
    .a1(mux1[1]),
    .s0(key_idx)
  );
  mux2 #(.WIDTH(16)) mpmux6 (
    .x(read_data2),
    .a0(mux2[0]),
    .a1(mux2[1]),
    .s0(key_idx)
  );
  // Read mux 3
  logic [3:0] mux3 [3:0];
  mux4 #(.WIDTH(4)) mpmux7 (
    .x(mux3[0]),
    .a0(keys[0*16 +: 4]),
    .a1(keys[1*16 +: 4]),
    .a2(keys[2*16 +: 4]),
    .a3(keys[3*16 +: 4]),
    .s0(read_addr3[0]),
    .s1(read_addr3[1])
  );
  mux4 #(.WIDTH(4)) mpmux8 (
    .x(mux3[1]),
    .a0(keys[4*16 +: 4]),
    .a1(keys[5*16 +: 4]),
    .a2(keys[6*16 +: 4]),
    .a3(keys[7*16 +: 4]),
    .s0(read_addr3[0]),
    .s1(read_addr3[1])
  );
  mux4 #(.WIDTH(4)) mpmux9 (
    .x(mux3[2]),
    .a0(keys[8*16  +: 4]),
    .a1(keys[9*16  +: 4]),
    .a2(keys[10*16 +: 4]),
    .a3(keys[11*16 +: 4]),
    .s0(read_addr3[0]),
    .s1(read_addr3[1])
  );
  mux4 #(.WIDTH(4)) mpmux10 (
    .x(mux3[3]),
    .a0(keys[12*16 +: 4]),
    .a1(keys[13*16 +: 4]),
    .a2(keys[14*16 +: 4]),
    .a3(keys[15*16 +: 4]),
    .s0(read_addr3[0]),
    .s1(read_addr3[1])
  );
  mux4 #(.WIDTH(4)) mpmux11 (
    .x(read_data3),
    .a0(mux3[0]),
    .a1(mux3[1]),
    .a2(mux3[2]),
    .a3(mux3[3]),
    .s0(read_addr3[2]),
    .s1(key_idx)
  );

  // Read addr gen
  always_comb begin
    read_addr1 = word_idx - shift_idx[2:1];
    read_addr2 = word_idx - shift_idx[2:1] + {1'b0, shift_idx[0]} + 2'b01;
    read_addr3 = {1'b0, word_idx} - shift_idx + 3'b10;
  end

  // Shifter module
  logic [31:0] swapped;
  logic [2:0] shift_ctl;
  logic [35:0] shift_view;
  logic [31:0] shifted;
  assign swapped = shift_idx[0] ? {read_data1, read_data2} : {read_data2, read_data1};
  always_comb begin
    case(shift_idx)
      'b000: shift_ctl = 'b000;
      'b001: shift_ctl = 'b001;
      'b010: shift_ctl = 'b010;
      'b011: shift_ctl = 'b011;
      'b100: shift_ctl = 'b100;
      'b101: shift_ctl = 'b011;
      'b110: shift_ctl = 'b010;
      'b111: shift_ctl = 'b001;
      default: shift_ctl = 3'bx; // unreachable
    endcase
    shift_view = {read_data3, swapped};
    shifted = shift_view[shift_ctl +: 32];
  end
  assign key_out = shifted;
endmodule
