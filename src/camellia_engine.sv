`default_nettype none

module camellia_engine(
  input  logic clk,
  input  logic rst_n,

  input  logic test_mode,
  input  logic cmd_key,
  input  logic cmd_data,
  input  logic cmd_encrypt,
  input  logic cmd_decrypt,
  output logic ready,

  input  logic [7:0] data_in,
  output logic [7:0] data_out
);
  logic [63:0] tmp_control;

  logic [31:0] data_read;
  logic [31:0] data_write;

  placeholder_control ctl(
    .clk(clk),
    .in(test_mode),
    .ctl(tmp_control)
  );

  data_reg data_r(
    .clk(clk),
    .address(tmp_control[1:0]),
    .write_en(tmp_control[2]),
    .shift_en(tmp_control[3]),
    .data_in(data_write),
    .data_out(data_read),
    .shift_in(data_in),
    .shift_out(data_out)
  );

  key_reg key_r(
    .clk(clk),
    .latch_en(tmp_control[11:4]),
    .latch_in(data_read),
    .key_idx(tmp_control[12]),
    .shift_idx(tmp_control[15:13]),
    .word_idx(tmp_control[17:16]),
    .key_out(data_write)
  );

  assign ready = 'b0;

endmodule