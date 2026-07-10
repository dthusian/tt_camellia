`default_nettype none

module key_reg(
  input  wire clk,

  input  wire [7:0]  latch_en,
  input  wire [31:0] latch_in,

  input  wire [3:0]  read_addr,
  input  wire [2:0]  shift_idx,
  input  wire        save_en,

  output wire [31:0] key_out
);
  // Key latches
  logic [255:0] keys;
  logic [15:0] read_data;

`ifdef SYNTHESIS
  generate
    for(genvar i = 0; i < 256; i++) begin : g
      sky130_fd_sc_hd__dlxtp_1 mplatch(
        .Q(keys[i]),
        .D(latch_in[i & 'b11111]),
        .GATE(latch_en[i >> 5])
      );
    end
  endgenerate
`else
  always_latch begin
    if(latch_en[0]) keys[31:0] = latch_in;
    if(latch_en[1]) keys[63:32] = latch_in;
    if(latch_en[2]) keys[95:64] = latch_in;
    if(latch_en[3]) keys[127:96] = latch_in;
    if(latch_en[4]) keys[159:128] = latch_in;
    if(latch_en[5]) keys[191:160] = latch_in;
    if(latch_en[6]) keys[223:192] = latch_in;
    if(latch_en[7]) keys[255:224] = latch_in;
  end
`endif

  // Read muxes
  logic [15:0] mux1 [3:0];
  mux4 #(.WIDTH(16)) mpmux1 (
    .x(mux1[0]),
    .a0(keys[0*16 +: 16]),
    .a1(keys[1*16 +: 16]),
    .a2(keys[2*16 +: 16]),
    .a3(keys[3*16 +: 16]),
    .s0(read_addr[0]),
    .s1(read_addr[1])
  );
  mux4 #(.WIDTH(16)) mpmux2(
    .x(mux1[1]),
    .a0(keys[4*16 +: 16]),
    .a1(keys[5*16 +: 16]),
    .a2(keys[6*16 +: 16]),
    .a3(keys[7*16 +: 16]),
    .s0(read_addr[0]),
    .s1(read_addr[1])
  );
  mux4 #(.WIDTH(16)) mpmux3(
    .x(mux1[2]),
    .a0(keys[8*16  +: 16]),
    .a1(keys[9*16  +: 16]),
    .a2(keys[10*16 +: 16]),
    .a3(keys[11*16 +: 16]),
    .s0(read_addr[0]),
    .s1(read_addr[1])
  );
  mux4 #(.WIDTH(16)) mpmux4(
    .x(mux1[3]),
    .a0(keys[12*16 +: 16]),
    .a1(keys[13*16 +: 16]),
    .a2(keys[14*16 +: 16]),
    .a3(keys[15*16 +: 16]),
    .s0(read_addr[0]),
    .s1(read_addr[1])
  );
  mux4 #(.WIDTH(16)) mpmux5(
    .x(read_data),
    .a0(mux1[0]),
    .a1(mux1[1]),
    .a2(mux1[2]),
    .a3(mux1[3]),
    .s0(read_addr[2]),
    .s1(read_addr[3])
  );

  // Shifter module
  logic [3:0] buf1;
  dff_en #(.WIDTH(4)) buf1_ff(
    .q(buf1),
    .clk,
    .d(read_data[3:0]),
    .de(save_en)
  );

  logic [1:0] shift_ctl;
  logic [15:0] shifted1;
  logic [15:0] shifted;
  always_comb begin
    case(shift_idx)
      'b000: shift_ctl = 'b00;
      'b001: shift_ctl = 'b00;
      'b010: shift_ctl = 'b01;
      'b011: shift_ctl = 'b10;
      'b100: shift_ctl = 'b11;
      'b101: shift_ctl = 'b10;
      'b110: shift_ctl = 'b01;
      'b111: shift_ctl = 'b00;
      default: shift_ctl = 2'bxx; // unreachable
    endcase

    shifted = shift_idx == 3'b000 ? read_data : shifted1;
  end
  mux4 #(.WIDTH(16)) shift_mux(
    .x(shifted1),
    .a0({buf1[0], read_data[15:1]}),
    .a1({buf1[1:0], read_data[15:2]}),
    .a2({buf1[2:0], read_data[15:3]}),
    .a3({buf1, read_data[15:4]}),
    .s0(shift_ctl[0]),
    .s1(shift_ctl[1])
  );

  logic [15:0] buf2;
  dff_en #(.WIDTH(16)) buf2_ff(
    .q(buf2),
    .clk,
    .d(shifted),
    .de(save_en)
  );
  assign key_out = {buf2, shifted};
endmodule
