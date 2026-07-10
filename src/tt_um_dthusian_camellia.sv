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
  camellia_engine engine(
    .clk(clk),
    .rst_n(rst_n),
    
    .test_mode(uio_in[0]),
    .cmd_key(uio_in[1]),
    .cmd_data(uio_in[2]),
    .cmd_encrypt(uio_in[3]),
    .cmd_decrypt(uio_in[4]),
    .ready(uio_out[5]),

    .data_in(ui_in),
    .data_out(uo_out)
  );

  assign uio_out[4:0] = 'b0;
  assign uio_out[7:6] = 'b0;
  assign uio_oe = 'b00100000; // only in

  // List all unused inputs to prevent warnings
  // slang lint_off unused-net
  wire _unused = &{ena, clk, rst_n, uio_in, ui_in};

endmodule
