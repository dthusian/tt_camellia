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
  logic swap_halves;
  logic [2:0] shift_ctl;
  logic [31:0] swapped;
  logic [35:0] shifted0;
  logic [33:0] shifted1;
  logic [31:0] shifted2;
  always_comb begin
    swap_halves = shift_idx[0];
    case(shift_idx)
      'b000: shift_ctl = 'b100;
      'b001: shift_ctl = 'b000;
      'b010: shift_ctl = 'b001;
      'b011: shift_ctl = 'b010;
      'b100: shift_ctl = 'b011;
      'b101: shift_ctl = 'b010;
      'b110: shift_ctl = 'b001;
      'b111: shift_ctl = 'b000;
      default: shift_ctl = 2'bxx; // unreachable
    endcase
  end
  mux2 #(.WIDTH(32)) kmux1 (
    .x(swapped),
    .a0({read_data2, read_data1}),
    .a1({read_data1, read_data2}),
    .s0(swap_halves)
  );
  assign shifted0 = {read_data3, swapped};
  mux2 #(.WIDTH(34)) kmux2 (
    .x(shifted1),
    .a0(shifted0[34:1]),
    .a1(shifted0[35:2]),
    .s0(shift_ctl[0])
  );
  mux2 #(.WIDTH(32)) kmux3 (
    .x(shifted2),
    .a0(shifted1[31:0]),
    .a1(shifted1[33:2]),
    .s0(shift_ctl[1])
  );
  mux2 #(.WIDTH(32)) kmux4 (
    .x(key_out),
    .a0(shifted2),
    .a1(swapped),
    .s0(shift_ctl[2])
  );
endmodule
