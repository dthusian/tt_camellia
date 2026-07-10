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
    for(genvar i = 0; i < 16; i++) begin : h
      logic [3:0] mux1;

      sky130_fd_sc_hd__mux4_1 mpmux1(
        .X(mux1[0]),
        .A0(keys[0*16+i]),
        .A1(keys[1*16+i]),
        .A2(keys[2*16+i]),
        .A3(keys[3*16+i]),
        .S0(read_addr[0]),
        .S1(read_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux2(
        .X(mux1[1]),
        .A0(keys[4*16+i]),
        .A1(keys[5*16+i]),
        .A2(keys[6*16+i]),
        .A3(keys[7*16+i]),
        .S0(read_addr[0]),
        .S1(read_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3(
        .X(mux1[2]),
        .A0(keys[8*16+i]),
        .A1(keys[9*16+i]),
        .A2(keys[10*16+i]),
        .A3(keys[11*16+i]),
        .S0(read_addr[0]),
        .S1(read_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux4(
        .X(mux1[3]),
        .A0(keys[12*16+i]),
        .A1(keys[13*16+i]),
        .A2(keys[14*16+i]),
        .A3(keys[15*16+i]),
        .S0(read_addr[0]),
        .S1(read_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux5(
        .X(read_data[i]),
        .A0(mux1[0]),
        .A1(mux1[1]),
        .A2(mux1[2]),
        .A3(mux1[3]),
        .S0(read_addr[2]),
        .S1(read_addr[3])
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

  always_comb begin
    read_data = keys[{read_addr, 4'b0} +: 16];
  end
`endif

  // Shifter module
  logic [3:0] buf1;
  always_ff @(posedge clk) begin
    if(save_en) begin
      buf1 <= read_data[3:0];
    end
  end

  logic [15:0] shifted;
  always_comb begin
    case(shift_idx)
      'b000: shifted = read_data;
      'b001: shifted = {buf1[0], read_data[15:1]};
      'b010: shifted = {buf1[1:0], read_data[15:2]};
      'b011: shifted = {buf1[2:0], read_data[15:3]};
      'b100: shifted = {buf1, read_data[15:4]};
      'b101: shifted = {buf1[2:0], read_data[15:3]};
      'b110: shifted = {buf1[1:0], read_data[15:2]};
      'b111: shifted = {buf1[0], read_data[15:1]};
      default: shifted = 16'hxxxx; // unreachable
    endcase
  end

  logic [15:0] buf2;
  always_ff @(posedge clk) begin
    if(save_en) begin
      buf2 <= shifted;
    end
  end
  assign key_out = {buf2, shifted};
endmodule
