`default_nettype none

module camellia_engine(
  input  wire clk,
  input  wire rst_n,

  input  wire test_mode,
  input  wire cmd_key,
  input  wire cmd_data,
  input  wire cmd_encrypt,
  input  wire cmd_decrypt,
  output wire ready,

  input  wire [7:0] data_in,
  output var  [7:0] data_out
);
  logic [23:0] tmp_control;

  logic [31:0] s0;
  logic [31:0] s1;
  logic [31:0] s2;
  logic [31:0] s3;

  always_ff @(posedge clk) begin
    s0 <= {data_in, s0[31:8]};
  end

  control ctl(
    .clk(clk),
    .rst(~rst_n),
    .test_mode(test_mode),
    .cmd_key(cmd_key),
    .cmd_data(cmd_data),
    .cmd_encrypt(cmd_encrypt),
    .cmd_decrypt(cmd_decrypt),
    .ctl(tmp_control)
  );

  data_reg data_r(
    .clk(clk),
    .read_addr(tmp_control[2:0]),
    .write_addr(tmp_control[2:0]),
    .write_en(tmp_control[2]),
    .data_in(s0),
    .data_out(s1)
  );

  key_reg key_r(
    .latch_en(tmp_control[11:4]),
    .latch_in(s1),
    .key_idx(tmp_control[12]),
    .shift_idx(tmp_control[15:13]),
    .word_idx(tmp_control[17:16]),
    .key_out(s2)
  );

  ops op(
    .clk(clk),
    .subcycle(tmp_control[23:22]),
    .opcode(tmp_control[21:19]),
    .data_b(s2),
    .data_a(s1),
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
