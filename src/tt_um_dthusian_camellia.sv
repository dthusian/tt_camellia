/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_dthusian_camellia (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);
  logic [63:0] write_port;
  logic [63:0] read_port;
  logic [7:0] byte_read;
  logic [7:0] byte_en;
  
  assign write_port = {ui_in, ui_in, ui_in, ui_in, ui_in, ui_in, ui_in, ui_in};

  data_reg r(
    .clk(clk),
    .rst(~rst_n),
    .address(uio_in[3]),
    .write_en(uio_in[4]),
    .xor_en(uio_in[5]),
    .byte_en(byte_en),
    .in_data(write_port),
    .out_data(read_port)
  );

  always_comb begin
    case(uio_in[2:0])
      'b000: byte_en = 'h1;
      'b001: byte_en = 'h2;
      'b010: byte_en = 'h4;
      'b011: byte_en = 'h8;
      'b100: byte_en = 'h10;
      'b101: byte_en = 'h20;
      'b110: byte_en = 'h40;
      'b111: byte_en = 'h80;
      default: byte_en = 'b0;
    endcase
    case(uio_in[2:0])
      'h7: byte_read = read_port[63:56];
      'h6: byte_read = read_port[55:48];
      'h5: byte_read = read_port[47:40];
      'h4: byte_read = read_port[39:32];
      'h3: byte_read = read_port[31:24];
      'h2: byte_read = read_port[23:16];
      'h1: byte_read = read_port[15:8];
      'h0: byte_read = read_port[7:0];
      default: byte_read = 'b0;
    endcase
  end

  assign uo_out = byte_read;

  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, uio_in, ui_in};
  assign uio_out = {8'b0};

endmodule
