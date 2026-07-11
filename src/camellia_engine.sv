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
  // data path
  logic [31:0] input_word;
  logic [31:0] data_read1;
  logic [31:0] data_read2;
  logic [31:0] key_result;
  logic [31:0] sigma_result;
  logic [31:0] result;

  // control signals
  logic       input_mux;
  logic [2:0] data_read_addr1;
  logic [1:0] data_read_addr2;
  logic [1:0] data_fwd;
  logic       data_write_addr;
  logic       data_write_en;
  logic [3:0] data_write_bs;
  logic [7:0] key_latch_en;
  logic       key_key_idx;
  logic [1:0] key_word_idx;
  logic [2:0] key_shift_idx;
  logic [2:0] sigma_read_addr;
  logic [1:0] op_subcycle;
  logic [2:0] op_opcode;
  logic [1:0] output_mux;

  assign input_word = {data_in, data_in, data_in, data_in};

  control ctl(
    .clk,
    .rst(~rst_n),

    .test_mode,
    .cmd_key,
    .cmd_data,
    .cmd_encrypt,
    .cmd_decrypt,

    .ready,
    .input_mux,
    .data_read_addr1,
    .data_read_addr2,
    .data_fwd,
    .data_write_addr,
    .data_write_en,
    .data_write_bs,
    .key_latch_en,
    .key_key_idx,
    .key_word_idx,
    .key_shift_idx,
    .sigma_read_addr,
    .op_subcycle,
    .op_opcode,
    .output_mux
  );

  key_reg key_r(
    .latch_en(key_latch_en),
    .latch_in(data_read1),
    .key_idx(key_key_idx),
    .word_idx(key_word_idx),
    .shift_idx(key_shift_idx),
    .key_out(key_result)
  );

  sigma_table sig_table(
    .addr(sigma_read_addr),
    .data(sigma_result)
  );

  data_reg data_r(
    .clk,
    .key_result,
    .sigma_result,
    .read_addr1(data_read_addr1),
    .read_data1(data_read1),
    .read_addr2(data_read_addr2),
    .read_data2(data_read2),
    .fwd(data_fwd),
    .write_addr(data_write_addr),
    .write_en(data_write_en),
    .write_bs(data_write_bs),
    .write_data(input_mux ? input_word : result)
  );

  ops op(
    .clk,
    .subcycle(op_subcycle),
    .opcode(op_opcode),
    .data_a(data_read1),
    .data_b(data_read2),
    .result
  );

  mux4 #(.WIDTH(8)) out_mux(
    .x(data_out),
    .a0(data_read1[7:0]),
    .a1(data_read1[15:8]),
    .a2(data_read1[23:16]),
    .a3(data_read1[31:24]),
    .s0(output_mux[0]),
    .s1(output_mux[1])
  );
endmodule
