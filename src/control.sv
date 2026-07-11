`default_nettype none

/*
# Microcode summary

fa:
r4 <- sb1 r1 kr
r5 <- sb2 r0 kr
r4 <- xs1 r4 r5
r5 <- xs2 r5 r4
r4 <- xs3 r4 r5
r5 <- xs3 r5 r4
r4 <- xor r2 r4
r5 <- xor r3 r5
r2, r3 <- r4, r5

fb:
r4 <- sb1 r3 kr
r5 <- sb2 r2 kr
r4 <- xs1 r4 r5
r5 <- xs2 r5 r4
r4 <- xs3 r4 r5
r5 <- xs3 r5 r4
r4 <- xor r2 r4
r5 <- xor r3 r5
r0, r1 <- r4, r5

fl:
r4 <- fla r3 kr
r4 <- xor r2 r4
r5 <- flb r4 kr
r5 <- xor r3 r5
r2, r3 <- r4, r5
r5 <- flb r0 kr
r5 <- xor r1 r5
r4 <- fla r5 kr
r4 <- xor r0 r4
r0, r1 <- r4, r5
*/

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
  output wire [3:0] data_write_bs,
  output wire [7:0] key_latch_en,
  output wire       key_key_idx,
  output wire [1:0] key_word_idx,
  output wire [2:0] key_shift_idx,
  output wire [2:0] sigma_read_addr,
  output wire [1:0] op_subcycle,
  output wire [2:0] op_opcode,
  output wire [1:0] output_mux
);
  logic [14:0] ctl;
  always_ff @(posedge clk) begin
    ctl <= {ctl[13:0], test_mode};
  end

  assign input_mux = cmd_data;
  assign data_read_addr1 = ctl[2:0];
  assign data_read_addr2 = ctl[4:3];
  assign data_fwd = ctl[7:6];
  assign data_write_addr = ctl[1];
  assign data_write_en = ctl[5];
  assign data_write_bs = ctl[13:10];
  assign key_latch_en = ctl[11:4];
  assign key_key_idx = ctl[10];
  assign key_word_idx = ctl[8:7];
  assign key_shift_idx = ctl[11:9];
  assign sigma_read_addr = ctl[14:12];
  assign op_subcycle = ctl[7:6];
  assign op_opcode = ctl[5:3];
  assign ready = cmd_key;
  assign output_mux = {cmd_encrypt, cmd_decrypt};
endmodule
