`default_nettype none

module tristate_buf #(
  parameter WIDTH = 16
)(
  input  logic [WIDTH-1:0] x,
  input  logic             en,
  inout  logic [WIDTH-1:0] y
);
  assign y = en ? x : {WIDTH{1'bz} };
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
  logic [255:0] keys;
  // Tri-state bus to read 16+16+4 bits
  // This solution uses 1.25 tri-state buffers per key bit
  logic [15:0] bus1;
  logic [15:0] bus2;
  logic [3:0] bus3;
  logic [2:0] bus1_addr;
  logic [2:0] bus2_addr;
  logic [3:0] bus3_addr;
  logic [7:0] bus1_sel;
  logic [7:0] bus2_sel;
  logic [15:0] bus3_sel;

`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < 256; i++) begin : mpgen1
      sky130_fd_sc_hd__dlxtp_1 mplatch(
        .Q(keys[i]),
        .D(latch_in[i >> 5]),
        .GATE(latch_en[i & 'b11111])
      );
    end
    for(genvar i = 0; i < 16; i++) begin : mpgen2
      logic bus1_mux1;
      logic bus1_mux2;
      logic bus2_mux1;
      logic bus2_mux2;
      sky130_fd_sc_hd__mux4_1 mpmux1(
        .X(bus1_mux1),
        .A0(keys[0*32+i]),
        .A1(keys[1*32+i]),
        .A2(keys[2*32+i]),
        .A3(keys[3*32+i]),
        .S0(bus1_addr[0]),
        .S1(bus1_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux2(
        .X(bus1_mux2),
        .A0(keys[4*32+i]),
        .A1(keys[5*32+i]),
        .A2(keys[6*32+i]),
        .A3(keys[7*32+i]),
        .S0(bus1_addr[0]),
        .S1(bus1_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3(
        .X(bus2_mux1),
        .A0(keys[0*32+i+16]),
        .A1(keys[1*32+i+16]),
        .A2(keys[2*32+i+16]),
        .A3(keys[3*32+i+16]),
        .S0(bus2_addr[0]),
        .S1(bus2_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux4(
        .X(bus2_mux2),
        .A0(keys[4*32+i+16]),
        .A1(keys[5*32+i+16]),
        .A2(keys[6*32+i+16]),
        .A3(keys[7*32+i+16]),
        .S0(bus2_addr[0]),
        .S1(bus2_addr[1])
      );
      assign bus1[i] = bus1_addr[2] ? bus1_mux1 : bus1_mux2;
      assign bus2[i] = bus2_addr[2] ? bus2_mux1 : bus2_mux2;
    end
    for(genvar i = 0; i < 4; i++) begin : mpgen3
      logic [3:0] bus3_mux;
      sky130_fd_sc_hd__mux4_1 mpmux5(
        .X(bus3_mux[0]),
        .A0(keys[0*16+i]),
        .A1(keys[1*16+i]),
        .A2(keys[2*16+i]),
        .A3(keys[3*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux6(
        .X(bus3_mux[1]),
        .A0(keys[4*16+i]),
        .A1(keys[5*16+i]),
        .A2(keys[6*16+i]),
        .A3(keys[7*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux7(
        .X(bus3_mux[2]),
        .A0(keys[8*16+i]),
        .A1(keys[9*16+i]),
        .A2(keys[10*16+i]),
        .A3(keys[11*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux8(
        .X(bus3_mux[3]),
        .A0(keys[12*16+i]),
        .A1(keys[13*16+i]),
        .A2(keys[14*16+i]),
        .A3(keys[15*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux9(
        .X(bus3[i]),
        .A0(bus3_mux[0]),
        .A1(bus3_mux[1]),
        .A2(bus3_mux[2]),
        .A3(bus3_mux[3]),
        .S0(bus3_addr[2]),
        .S1(bus3_addr[3])
      );
    end
  endgenerate
`else
  always_latch begin
    if(latch_en[0]) keys[31:0] = latch_in;
    if(latch_en[1]) keys[63:32] = latch_in;
    if(latch_en[2]) keys[95:64] = latch_in;
    if(latch_en[3]) keys[127:96] = latch_in;
    if(latch_en[4]) keys[31:0] = latch_in;
    if(latch_en[5]) keys[63:32] = latch_in;
    if(latch_en[6]) keys[95:64] = latch_in;
    if(latch_en[7]) keys[127:96] = latch_in;
  end

  generate
    for(genvar i = 0; i < 8; i++) begin
      tristate_buf key1(.x(keys[i*32+15:i*32+0]), .en(bus1_sel[i]), .y(bus1));
      tristate_buf key2(.x(keys[i*32+31:i*32+16]), .en(bus2_sel[i]), .y(bus2));
    end
    for(genvar j = 0; j < 16; j++) begin
      tristate_buf #(.WIDTH(4)) key3(.x(keys[j*16+3:j*16]), .en(bus3_sel[j]), .y(bus3));
    end
  endgenerate
`endif

  // Address decoder
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