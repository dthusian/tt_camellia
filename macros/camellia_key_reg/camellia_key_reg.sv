`default_nettype none

module camellia_key_reg(
  input  logic [7:0]  latch_en,
  input  logic [31:0] latch_in,

  input  logic [2:0] bus1_addr,
  input  logic [2:0] bus2_addr,
  input  logic [3:0] bus3_addr,
  output logic [15:0] bus1,
  output logic [15:0] bus2,
  output logic [3:0]  bus3
);
  logic [255:0] keys;
  logic [255:0] key_write;
  assign key_write = {latch_in, keys[255:32]};
  generate
    for(genvar i = 0; i < 256; i++) begin : mpgen1
      sky130_fd_sc_hd__dlxtp_1 mplatch(
        .Q(keys[i]),
        .D(key_write[i]),
        .GATE(latch_en[i >> 5])
      );
    end

    for(genvar i = 0; i < 16; i++) begin : mpgen2
      logic bus1_mux1;
      logic bus1_mux2;
      sky130_fd_sc_hd__mux4_1 mpmux1a(
        .X(bus1_mux1),
        .A0(keys[0*32+i]),
        .A1(keys[1*32+i]),
        .A2(keys[2*32+i]),
        .A3(keys[3*32+i]),
        .S0(bus1_addr[0]),
        .S1(bus1_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux1b(
        .X(bus1_mux2),
        .A0(keys[4*32+i]),
        .A1(keys[5*32+i]),
        .A2(keys[6*32+i]),
        .A3(keys[7*32+i]),
        .S0(bus1_addr[0]),
        .S1(bus1_addr[1])
      );
      sky130_fd_sc_hd__mux2_1 mpmux1c(
        .X(bus1[i]),
        .A0(bus1_mux1),
        .A1(bus1_mux2),
        .S(bus1_addr[2])
      );

      logic bus2_mux1;
      logic bus2_mux2;
      sky130_fd_sc_hd__mux4_1 mpmux2a(
        .X(bus2_mux1),
        .A0(keys[0*32+i+16]),
        .A1(keys[1*32+i+16]),
        .A2(keys[2*32+i+16]),
        .A3(keys[3*32+i+16]),
        .S0(bus2_addr[0]),
        .S1(bus2_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux2b(
        .X(bus2_mux2),
        .A0(keys[4*32+i+16]),
        .A1(keys[5*32+i+16]),
        .A2(keys[6*32+i+16]),
        .A3(keys[7*32+i+16]),
        .S0(bus2_addr[0]),
        .S1(bus2_addr[1])
      );
      sky130_fd_sc_hd__mux2_1 mpmux2c(
        .X(bus2[i]),
        .A0(bus2_mux1),
        .A1(bus2_mux2),
        .S(bus2_addr[2])
      );
    end

    for(genvar i = 0; i < 4; i++) begin : mpgen3
      logic [3:0] bus3_mux;
      sky130_fd_sc_hd__mux4_1 mpmux3a(
        .X(bus3_mux[0]),
        .A0(keys[0*16+i]),
        .A1(keys[1*16+i]),
        .A2(keys[2*16+i]),
        .A3(keys[3*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3b(
        .X(bus3_mux[1]),
        .A0(keys[4*16+i]),
        .A1(keys[5*16+i]),
        .A2(keys[6*16+i]),
        .A3(keys[7*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3c(
        .X(bus3_mux[2]),
        .A0(keys[8*16+i]),
        .A1(keys[9*16+i]),
        .A2(keys[10*16+i]),
        .A3(keys[11*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3d(
        .X(bus3_mux[3]),
        .A0(keys[12*16+i]),
        .A1(keys[13*16+i]),
        .A2(keys[14*16+i]),
        .A3(keys[15*16+i]),
        .S0(bus3_addr[0]),
        .S1(bus3_addr[1])
      );
      sky130_fd_sc_hd__mux4_1 mpmux3e(
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

endmodule