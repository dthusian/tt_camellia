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

  logic [31:0] s0;
  logic [31:0] s1;
  logic [31:0] s2;
  logic [31:0] s3;

  always_ff @(posedge clk) begin
    s0 <= {data_in, s0[31:8]};
  end

  placeholder_control ctl(
    .clk(clk),
    .in(test_mode),
    .ctl(tmp_control)
  );

  data_reg data_r(
    .clk(clk),
    .read_addr(tmp_control[1:0]),
    .write_addr(tmp_control[1:0]),
    .write_en(tmp_control[2]),
    .data_in(s0),
    .data_out(s1)
  );

  key_reg key_r(
    .clk(clk),
    .latch_en(tmp_control[11:4]),
    .latch_in(s1),
    .key_idx(tmp_control[12]),
    .shift_idx(tmp_control[15:13]),
    .word_idx(tmp_control[17:16]),
    .key_out(s2)
  );

  ops op(
    .clk(clk),
    .wordsel(tmp_control[21]),
    .opcode(tmp_control[20:19]),
    .key(s2),
    .data(s1),
    .result(s3)
  );

  always_comb begin
    case({tmp_control[3], tmp_control[18]})
      'b00: data_out = s3[7:0];
      'b01: data_out = s3[15:8];
      'b10: data_out = s3[23:16];
      'b11: data_out = s3[31:24];
      default: data_out = 'b0;
    endcase
  end

  assign ready = 'b0;

endmodule