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
  logic [127:0] key_l;
  logic [127:0] key_a;
  logic [63:0] key_out;
  logic [7:0] shift_in;
  
  assign uio_out[5:0] = read_port[45:40];
  assign write_port = {uio_in, uio_in, uio_in, uio_in, uio_in, uio_in, uio_in, uio_in};

  data_reg data_r(
    .clk(clk),
    .rst(~rst_n),
    .address(uio_in[0]),
    .write_en(uio_in[1]),
    .shift_en(uio_in[2]),
    .data_in(write_port),
    .data_out(read_port),
    .shift_in(shift_in),
    .shift_out(uo_out)
  );

  key_reg key_r1(
    .clk(clk),
    .rst(~rst_n),
    .shift_en(uio_in[4]),
    .shift_in(uo_out),
    .key_out(key_l)
  );

  key_reg key_r2(
    .clk(clk),
    .rst(~rst_n),
    .shift_en(uio_in[5]),
    .shift_in(uo_out),
    .key_out(key_a)
  );

  key_shifter key_shift(
    .key_l(key_l),
    .key_a(key_a),
    .word_sel(uio_in[7:6]),
    .shift(uio_in[2:0]),
    .key_out(key_out)
  );

  assign uio_out[6] = &{key_out};
  assign uio_out[7] = &{key_out};

  assign shift_in = uio_in[3] ? ui_in : uo_out ^ ui_in; 
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, uio_in, ui_in};

endmodule
