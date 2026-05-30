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
  logic [7:0] out0;
  logic [7:0] out1;
  logic [7:0] out2;
  logic [7:0] out3;
  logic [7:0] out4;
  logic [7:0] out5;
  logic [7:0] out6;
  logic [7:0] out7;
  sbox_impl1 sbox0(.in(ui_in), .out(out0));
  sbox_impl1 sbox1(.in({ui_in[6:0], ui_in[7]}), .out(out1));
  sbox_impl1 sbox2(.in({ui_in[5:0], ui_in[7:6]}), .out(out2));
  sbox_impl1 sbox3(.in({ui_in[4:0], ui_in[7:5]}), .out(out3));
  sbox_impl1 sbox4(.in({ui_in[3:0], ui_in[7:4]}), .out(out4));
  sbox_impl1 sbox5(.in({ui_in[2:0], ui_in[7:3]}), .out(out5));
  sbox_impl1 sbox6(.in({ui_in[1:0], ui_in[7:2]}), .out(out6));
  sbox_impl1 sbox7(.in({ui_in[0], ui_in[7:1]}), .out(out7));
  assign uo_out = out0 ^ out1 ^ out2 ^ out3 ^ out4 ^ out5 ^ out6 ^ out7;

  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0, uio_in};

endmodule
