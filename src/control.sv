`default_nettype none

// slang lint_off unused-port

// placeholder control module to ensure other logic is not optimized away
module control(
  input  wire clk,
  input  wire rst,
  input  wire test_mode,
  input  wire cmd_key,
  input  wire cmd_data,
  input  wire cmd_encrypt,
  input  wire cmd_decrypt,
  
  output wire       ready,
  output wire       input_mux,
  output wire [2:0] read_addr1,
  output wire [1:0] read_addr2,
  output wire [2:0] write_addr,
  output wire       write_en,
  output wire [7:0] key_latch_en,
  output wire       key_idx,
  output wire [2:0] shift_idx,
  output wire [1:0] word_idx,
  output wire [1:0] subcycle,
  output wire [2:0] opcode,
  output wire [1:0] output_mux
);
  logic [11:0] ctl;
  always_ff @(posedge clk) begin
    ctl <= {ctl[10:0], test_mode};
  end

  assign read_addr1 = ctl[2:0];
  assign read_addr2 = ctl[4:3];
  assign write_addr = ctl[2:0];
  assign write_en = ctl[5];
  assign key_latch_en = ctl[11:4];
  assign key_idx = ctl[6];
  assign shift_idx = ctl[9:7];
  assign word_idx = ctl[11:10];
  assign subcycle = ctl[7:6];
  assign opcode = ctl[5:3];
  assign ready = cmd_key;
  assign input_mux = cmd_data;
  assign output_mux = {cmd_encrypt, cmd_decrypt};
endmodule
