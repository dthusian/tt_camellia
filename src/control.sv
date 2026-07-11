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
  output wire [2:0] data_read_addr1,
  output wire [1:0] data_read_addr2,
  output wire [1:0] data_fwd,
  output wire       data_write_addr,
  output wire       data_write_en,
  output wire [7:0] key_latch_en,
  output wire [3:0] key_read_addr,
  output wire [2:0] key_shift_idx,
  output wire       key_save_en,
  output wire [1:0] op_subcycle,
  output wire [2:0] op_opcode,
  output wire [1:0] output_mux
);
  logic [11:0] ctl;
  always_ff @(posedge clk) begin
    ctl <= {ctl[10:0], test_mode};
  end

  assign input_mux = cmd_data;
  assign data_read_addr1 = ctl[2:0];
  assign data_read_addr2 = ctl[4:3];
  assign data_fwd = ctl[7:6];
  assign data_write_addr = ctl[1];
  assign data_write_en = ctl[5];
  assign key_latch_en = ctl[11:4];
  assign key_read_addr = ctl[10:7];
  assign key_shift_idx = ctl[11:9];
  assign key_save_en = ctl[6];
  assign op_subcycle = ctl[7:6];
  assign op_opcode = ctl[5:3];
  assign ready = cmd_key;
  assign output_mux = {cmd_encrypt, cmd_decrypt};
endmodule
