`default_nettype none

module tristate_buf #(
  parameter WIDTH = 16
)(
  input  logic [WIDTH-1:0] x,
  input  logic             en,
  inout  logic [WIDTH-1:0] y
);
  generate
    for(genvar i = 0; i < WIDTH; i++) begin
      sky130_fd_sc_hd__ebufn_2 tribuf(
        .Z(y[i]),
        .A(x[i]),
        .TE_B(~en)
      );
    end
  endgenerate
endmodule

module key_reg(
  input  logic clk,

  input  logic [7:0]  latch_en,
  input  logic [31:0] latch_in,

  input  logic        key_idx,
  input  logic [2:0]  shift_idx,
  input  logic [1:0]  word_idx,

  output logic [31:0] key_out
);
  // Key latches
  logic [127:0] key_l;
  logic [127:0] key_a;

  always_latch begin
    if(latch_en[0]) key_l[31:0] = latch_in;
    if(latch_en[1]) key_l[63:32] = latch_in;
    if(latch_en[2]) key_l[95:64] = latch_in;
    if(latch_en[3]) key_l[127:96] = latch_in;
    if(latch_en[4]) key_a[31:0] = latch_in;
    if(latch_en[5]) key_a[63:32] = latch_in;
    if(latch_en[6]) key_a[95:64] = latch_in;
    if(latch_en[7]) key_a[127:96] = latch_in;
  end

  // Address decoder
  logic [2:0] bus1_addr;
  logic [2:0] bus2_addr;
  logic [3:0] bus3_addr;
  logic [7:0] bus1_sel;
  logic [7:0] bus2_sel;
  logic [15:0] bus3_sel;
  logic half_swap;
  always_comb begin
    bus1_addr[2] = key_idx;
    bus1_addr[1:0] = word_idx - shift_idx[2:1];
    bus2_addr[2] = key_idx;
    bus2_addr[1:0] = word_idx - shift_idx[2:1] + shift_idx[0] + 2'b01;
    bus3_addr[3] = key_idx;
    bus3_addr[2:0] = {1'b0, word_idx} - shift_idx + 3'b10;

    bus1_sel = 'b0;
    bus1_sel[bus1_addr] = 1'b1;
    bus2_sel = 'b0;
    bus2_sel[bus2_addr] = 1'b1;
    bus3_sel = 'b0;
    bus3_sel[bus3_addr] = 1'b1;

    half_swap = shift_idx[0];
  end

  // Tri-state bus to read 16+16+4 bits
  // This solution uses 1.25 tri-state buffers per key bit
  logic [15:0] bus1;
  logic [15:0] bus2;
  logic [3:0] bus3;
  generate
    for(genvar i = 0; i < 4; i++) begin
      tristate_buf key_l1(.x(key_l[i*32+15:i*32+0]), .en(bus1_sel[i]), .y(bus1));
      tristate_buf key_l2(.x(key_l[i*32+31:i*32+16]), .en(bus2_sel[i]), .y(bus2));
      tristate_buf key_a1(.x(key_a[i*32+15:i*32+0]), .en(bus1_sel[i+4]), .y(bus1));
      tristate_buf key_a2(.x(key_a[i*32+31:i*32+16]), .en(bus2_sel[i+4]), .y(bus2));
    end
    for(genvar j = 0; j < 8; j++) begin
      tristate_buf #(.WIDTH(4)) key_l3(.x(key_l[j*16+3:j*16]), .en(bus3_sel[j]), .y(bus3));
      tristate_buf #(.WIDTH(4)) key_a3(.x(key_a[j*16+3:j*16]), .en(bus3_sel[j+8]), .y(bus3));
    end
  endgenerate

  // Shifter module
  logic [31:0] swapped;
  logic [31:0] shifted;
  always_comb begin
    swapped = half_swap ? {bus2, bus1} : {bus1, bus2};
    case(shift_idx)
      'b000: shifted = swapped;
      'b001: shifted = {bus3[0], swapped[31:1]};
      'b010: shifted = {bus3[1:0], swapped[31:2]};
      'b011: shifted = {bus3[2:0], swapped[31:3]};
      'b100: shifted = {bus3, swapped[31:4]};
      'b101: shifted = {bus3[2:0], swapped[31:3]};
      'b110: shifted = {bus3[1:0], swapped[31:2]};
      'b111: shifted = {bus3[0], swapped[31:1]};
    endcase
  end
  assign key_out = shifted;
endmodule