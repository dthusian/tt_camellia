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
  logic [31:0] input_shift;
  logic [31:0] data_read1;
  logic [31:0] data_read2;
  logic [31:0] key_read;
  logic [31:0] sigma_read;
  logic [31:0] data_a;
  logic [31:0] data_b;
  logic [31:0] result;

  logic       input_mux;
  logic [2:0] read_addr1;
  logic [1:0] read_addr2;
  logic [2:0] write_addr;
  logic       write_en;
  logic [7:0] key_latch_en;
  logic       key_idx;
  logic [2:0] shift_idx;
  logic [1:0] word_idx;
  logic [1:0] subcycle;
  logic [2:0] opcode;
  logic [1:0] output_mux;

  // Input shift-reg
  always_ff @(posedge clk) begin
    input_shift <= {data_in, input_shift[31:8]};
  end

  control ctl(
    .clk,
    .rst(~rst_n),

    .test_mode,
    .cmd_key,
    .cmd_data,
    .cmd_encrypt,
    .cmd_decrypt,
    .read_addr1,
    .read_addr2,

    .ready,
    .input_mux,
    .write_addr,
    .write_en,
    .key_latch_en,
    .key_idx,
    .shift_idx,
    .word_idx,
    .subcycle,
    .opcode,
    .output_mux
  );

  data_reg data_r(
    .clk,
    .read_addr1,
    .read_data1(data_read1),
    .read_addr2({2'b11, read_addr2[0]}),
    .read_data2(data_read2),
    .write_addr,
    .write_en,
    .write_data(input_mux ? input_shift : result)
  );

  key_reg key_r(
    .latch_en(key_latch_en),
    .latch_in(data_read1),
    .key_idx,
    .shift_idx,
    .word_idx,
    .key_out(key_read)
  );

  sigma_table sig_table(
    .addr({key_idx, word_idx}),
    .data(sigma_read)
  );

  assign data_a = data_read1;
  assign data_b = read_addr2 == 2'b11 ? sigma_read :
    read_addr2 == 2'b10 ? key_read :
    data_read2;

  ops op(
    .clk,
    .subcycle,
    .opcode,
    .data_a,
    .data_b,
    .result
  );

  always_comb begin
    case(output_mux)
      'b00: data_out = data_read1[7:0];
      'b01: data_out = data_read1[15:8];
      'b10: data_out = data_read1[23:16];
      'b11: data_out = data_read1[31:24];
      default: data_out = 8'bx; // unreachable
    endcase
  end
endmodule
